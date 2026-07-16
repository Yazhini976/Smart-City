package handlers

import (
	"bytes"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/dchest/captcha"

	"smartcity/db"
	"smartcity/models"
)

var otpStore = make(map[string]string)

func generateOTP() string {
	rand.Seed(time.Now().UnixNano())
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

// Get Captcha (server-side graphical image)
func GetCaptcha(c *gin.Context) {
	id := captcha.NewLen(6) // Generates a 6-digit captcha
	var buf bytes.Buffer
	if err := captcha.WriteImage(&buf, id, 240, 80); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to render captcha"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"captcha_id":  id,
		"image_bytes": buf.Bytes(), // gin automatically encodes []byte as base64 string
	})
}

// Send OTP to terminal (for testing)
func SendOTP(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify captcha server-side
	if !captcha.VerifyString(req.CaptchaID, req.CaptchaAnswer) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Incorrect CAPTCHA"})
		return
	}

	// Validate phone number (starts with 6,7,8,9 and length 10)
	if len(req.PhoneNumber) != 10 || req.PhoneNumber[0] < '6' || req.PhoneNumber[0] > '9' {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number. Must be 10 digits and start with 6, 7, 8, or 9."})
		return
	}

	otp := generateOTP()
	otpStore[req.PhoneNumber] = otp

	// Print OTP to terminal
	fmt.Printf("\n========================================\n")
	fmt.Printf("📱 OTP for %s: %s\n", req.PhoneNumber, otp)
	fmt.Printf("========================================\n\n")

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent successfully", "phone": req.PhoneNumber})
}

// Verify OTP
func VerifyOTP(c *gin.Context) {
	var req models.OTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	storedOTP, exists := otpStore[req.PhoneNumber]
	if !exists || storedOTP != req.OTP {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid OTP"})
		return
	}

	delete(otpStore, req.PhoneNumber)

	// Check if this number belongs to an officer
	officer, err := db.GetOfficerByPhone(req.PhoneNumber)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	isOfficer := officer != nil

	// Get or Create User
	user, err := db.GetUserByPhone(req.PhoneNumber)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if user == nil {
		// New user: by default write to users table with name = 'citizen'
		user, err = db.CreateOrUpdateUser(req.PhoneNumber, "citizen")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	response := gin.H{
		"user_id":    user.UserID,
		"phone":      user.PhoneNumber,
		"role":       user.Name, // Map database users.name field to JSON 'role'
		"is_officer": isOfficer,
	}

	c.JSON(http.StatusOK, response)
}

// Update User Role after "Switch Profile" Dialog (Login as Citizen or Login as Staff)
func UpdateUserRole(c *gin.Context) {
	var req models.RoleUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	dbName := "citizen"
	if req.Role == "officer" {
		dbName = "officer"
	}

	err := db.UpdateUserRole(userID.(int), dbName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Role updated successfully",
		"role":    dbName,
	})
}

// Create Complaint
func CreateComplaint(c *gin.Context) {
	var req models.ComplaintRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user's phone number
	var userPhone string
	err := db.DB.QueryRow(`SELECT phone_number FROM users WHERE user_id = $1`, userID.(int)).Scan(&userPhone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user: " + err.Error()})
		return
	}

	// Find ward from location coordinates
	wardNo := FindWardByLocation(req.Latitude, req.Longitude)

	// Find officer mapped to this module and ward
	assignedOfficerID, err := db.GetOfficerForWard(req.ModuleID, wardNo)
	var assignedOfficerPtr *int
	if err == nil && assignedOfficerID > 0 {
		assignedOfficerPtr = &assignedOfficerID
	}

	// Serialize details into location column: "street|area|city|description"
	locationStr := fmt.Sprintf("%s|%s|%s|%s", req.Street, req.Area, req.City, req.Description)

	complaint := &models.Complaint{
		ComplaintID:       uuid.New(),
		UserPhone:         userPhone,
		ModuleID:          req.ModuleID,
		WardNo:            wardNo,
		AssignedOfficerID: assignedOfficerPtr,
		Location:          locationStr,
		Latitude:          req.Latitude,
		Longitude:         req.Longitude,
		ComplaintPhoto:    req.PhotoURL,
		Reason:            req.Title, // Title field maps to reason column
		Status:            "PENDING",
	}

	if err := db.CreateComplaint(complaint); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":             "Complaint created successfully",
		"complaint_id":        complaint.ComplaintID,
		"ward_no":             wardNo,
		"assigned_officer_id": assignedOfficerID,
	})
}

// Get User Complaints
func GetUserComplaints(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	complaints, err := db.GetComplaintsByCitizen(userID.(int))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, complaints)
}

// Get Officer Work Orders
func GetOfficerWorkOrders(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	officerID, err := db.GetOfficerIDByUserID(userID.(int))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Not a field officer: " + err.Error()})
		return
	}

	orders, err := db.GetWorkOrdersByOfficer(officerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, orders)
}

// Update Work Order (complaint status transitions)
func UpdateWorkOrder(c *gin.Context) {
	workOrderID := c.Param("id")
	var req models.WorkOrderUpdate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id, err := uuid.Parse(workOrderID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	if req.Remarks == "" {
		req.Remarks = "Status updated by officer"
	}

	if err := db.UpdateWorkOrderStatus(id, req.Status, req.Remarks); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Send feedback notification if the status was marked completed
	if req.Status == "completed" || req.Status == "COMPLETED" {
		var userPhone, reason string
		err := db.DB.QueryRow(`SELECT user_phone, reason FROM complaints WHERE complaint_id = $1`, id).Scan(&userPhone, &reason)
		if err == nil {
			fmt.Printf("\n======================================================================\n")
			fmt.Printf("💬 SMS sent to %s:\n", userPhone)
			fmt.Printf("Dear Citizen, your complaint regarding '%s' has been COMPLETED.\n", reason)
			fmt.Printf("Please share your feedback at: http://172.16.147.44:8081/api/feedback/%s\n", id.String())
			fmt.Printf("======================================================================\n\n")
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Work order updated successfully"})
}

// Get Modules list
func GetModules(c *gin.Context) {
	modules, err := db.GetModules()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, modules)
}

// LookupWard returns the ward number based on latitude and longitude coordinates
func LookupWard(c *gin.Context) {
	latStr := c.Query("latitude")
	lngStr := c.Query("longitude")

	var lat, lng float64
	fmt.Sscan(latStr, &lat)
	fmt.Sscan(lngStr, &lng)

	wardNo := FindWardByLocation(lat, lng)

	c.JSON(http.StatusOK, gin.H{
		"ward_no": wardNo,
	})
}

// Get Feedback HTML Page
func GetFeedbackPage(c *gin.Context) {
	id := c.Param("id")
	c.Header("Content-Type", "text/html")
	c.String(http.StatusOK, fmt.Sprintf(`
		<html>
			<head>
				<title>Complaint Feedback</title>
				<meta name="viewport" content="width=device-width, initial-scale=1">
				<style>
					body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f1f5f9; }
					.card { background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); text-align: center; max-width: 400px; width: 90%%; }
					h1 { color: #1e3a8a; margin-top: 0; }
					p { color: #475569; }
					textarea { width: 100%%; height: 100px; margin: 1rem 0; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px; box-sizing: border-box; }
					button { background: #1e3a8a; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }
				</style>
			</head>
			<body>
				<div class="card">
					<h1>Complaint Feedback</h1>
					<p>Complaint ID: %s</p>
					<p>How would you rate the resolution of your complaint?</p>
					<textarea placeholder="Write your feedback here..."></textarea>
					<button onclick="alert('Thank you for your feedback!')">Submit Feedback</button>
				</div>
			</body>
		</html>
	`, id))
}