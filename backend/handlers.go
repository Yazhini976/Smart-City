package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/dchest/captcha"
)

// ---------- 1. CAPTCHA ----------
// GET /api/captcha/new
// Generates a captcha SERVER-SIDE (never on the phone) and returns
// its id + a PNG image encoded as base64. The phone just displays
// the image and sends back what the user typed — it never knows
// or computes the answer itself. This is what "not local" means:
// the source of truth lives on this server, so the captcha keeps
// working as long as the phone can reach this server over the
// network (WiFi/mobile data) — it has nothing to do with the USB
// cable. The cable-only behavior you saw before was almost
// certainly because the app was pointed at 10.0.2.2 or an ADB
// reverse tunnel instead of your machine's real LAN IP.
func newCaptchaHandler(w http.ResponseWriter, r *http.Request) {
	id := captcha.New() // generates + stores the answer server-side

	imgBytes, err := renderCaptchaPNG(id)
	if err != nil {
		http.Error(w, "failed to render captcha", http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"captcha_id":  id,
		"image_bytes": imgBytes, // []byte auto-encodes to base64 in JSON
	})
}

func renderCaptchaPNG(id string) ([]byte, error) {
	buf := new(bytes.Buffer)
	if err := captcha.WriteImage(buf, id, captcha.StdWidth, captcha.StdHeight); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// ---------- 2. LOGIN (mobile number + captcha) -> sends OTP ----------
type loginRequest struct {
	MobileNumber   string `json:"mobile_number"`
	CaptchaID      string `json:"captcha_id"`
	CaptchaAnswer  string `json:"captcha_answer"`
}

// POST /api/login
func loginHandler(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	if len(req.MobileNumber) != 10 {
		http.Error(w, "mobile number must be 10 digits", http.StatusBadRequest)
		return
	}

	// Verify captcha server-side. VerifyString consumes the captcha
	// (single use) whether right or wrong.
	if !captcha.VerifyString(req.CaptchaID, req.CaptchaAnswer) {
		http.Error(w, "incorrect captcha", http.StatusUnauthorized)
		return
	}

	otp := generateOTP()
	otpHash := hashOTP(otp)
	expiresAt := time.Now().Add(5 * time.Minute)

	_, err := DB.Exec(
		`INSERT INTO otp_verifications (mobile_number, otp_hash, captcha_id, expires_at)
		 VALUES ($1, $2, $3, $4)`,
		req.MobileNumber, otpHash, req.CaptchaID, expiresAt,
	)
	if err != nil {
		log.Println("db insert error:", err)
		http.Error(w, "failed to create otp", http.StatusInternalServerError)
		return
	}

	// TODO: replace this with a real SMS gateway call (e.g. MSG91, Twilio).
	// For now the OTP is printed to the backend terminal so you can test
	// the flow end-to-end without an SMS account.
	fmt.Printf("\n>>> OTP for %s is: %s (valid 5 min)\n\n", req.MobileNumber, otp)

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message": "otp sent",
	})
}

// ---------- 3. OTP VERIFY -> tells the app if this is a staff number ----------
type verifyRequest struct {
	MobileNumber string `json:"mobile_number"`
	OTP          string `json:"otp"`
}

// POST /api/otp/verify
func verifyOTPHandler(w http.ResponseWriter, r *http.Request) {
	var req verifyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	otpHash := hashOTP(req.OTP)

	var id int
	var expiresAt time.Time
	err := DB.QueryRow(
		`SELECT id, expires_at FROM otp_verifications
		 WHERE mobile_number = $1 AND otp_hash = $2 AND verified = false
		 ORDER BY created_at DESC LIMIT 1`,
		req.MobileNumber, otpHash,
	).Scan(&id, &expiresAt)

	if err != nil {
		http.Error(w, "invalid otp", http.StatusUnauthorized)
		return
	}
	if time.Now().After(expiresAt) {
		http.Error(w, "otp expired", http.StatusUnauthorized)
		return
	}

	// Mark used
	if _, err := DB.Exec(`UPDATE otp_verifications SET verified = true WHERE id = $1`, id); err != nil {
		log.Println("db update error:", err)
	}

	// Ensure a citizens row exists for this number.
	if _, err := DB.Exec(
		`INSERT INTO citizens (mobile_number) VALUES ($1)
		 ON CONFLICT (mobile_number) DO NOTHING`,
		req.MobileNumber,
	); err != nil {
		log.Println("db upsert citizen error:", err)
	}

	// Check the staff whitelist. Only numbers in staff_numbers
	// get is_staff = true, so only they trigger the role popup
	// on the Flutter side.
	var isStaff bool
	err = DB.QueryRow(
		`SELECT EXISTS(SELECT 1 FROM staff_numbers WHERE mobile_number = $1)`,
		req.MobileNumber,
	).Scan(&isStaff)
	if err != nil {
		log.Println("db staff check error:", err)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message":  "otp verified",
		"is_staff": isStaff,
	})
}

// ---------- helpers ----------

func generateOTP() string {
	rand.Seed(time.Now().UnixNano())
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

func hashOTP(otp string) string {
	h := sha256.Sum256([]byte(otp))
	return hex.EncodeToString(h[:])
}

func writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}
