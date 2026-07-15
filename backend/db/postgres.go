package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	_ "github.com/lib/pq"

	"smartcity/models"
)

var DB *sql.DB

func InitDB() {
	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)

	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	if err = DB.Ping(); err != nil {
		log.Fatal("Database ping failed:", err)
	}
}

// ============================================
// USER QUERIES
// ============================================

func GetUserByPhone(phone string) (*models.User, error) {
	var user models.User
	query := `SELECT user_id, phone_number, COALESCE(name, '') as name, created_at
              FROM users WHERE phone_number = $1`

	err := DB.QueryRow(query, phone).Scan(
		&user.UserID, &user.PhoneNumber, &user.Name, &user.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func CreateOrUpdateUser(phone string, name string) (*models.User, error) {
	var user models.User
	query := `INSERT INTO users (phone_number, name) VALUES ($1, $2)
              ON CONFLICT (phone_number) DO UPDATE SET name = $2
              RETURNING user_id, phone_number, COALESCE(name, '') as name, created_at`
	err := DB.QueryRow(query, phone, name).Scan(
		&user.UserID, &user.PhoneNumber, &user.Name, &user.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func UpdateUserRole(userID int, name string) error {
	query := `UPDATE users SET name = $1 WHERE user_id = $2`
	_, err := DB.Exec(query, name, userID)
	return err
}

// ============================================
// OFFICER QUERIES
// ============================================

func GetOfficerByPhone(phone string) (*models.FieldOfficer, error) {
	var fo models.FieldOfficer
	query := `SELECT officer_id, module_id, officer_name, phone_number, ward_from, ward_to, is_active, created_at
              FROM field_officers WHERE phone_number = $1`
	err := DB.QueryRow(query, phone).Scan(
		&fo.OfficerID, &fo.ModuleID, &fo.OfficerName, &fo.PhoneNumber,
		&fo.WardFrom, &fo.WardTo, &fo.IsActive, &fo.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &fo, nil
}

func GetOfficerIDByUserID(userID int) (int, error) {
	var officerID int
	query := `SELECT fo.officer_id FROM field_officers fo
              JOIN users u ON u.phone_number = fo.phone_number
              WHERE u.user_id = $1`
	err := DB.QueryRow(query, userID).Scan(&officerID)
	return officerID, err
}

func GetOfficerForWard(moduleID, wardNo int) (int, error) {
	var officerID int
	query := `SELECT officer_id FROM ward_mapping
              WHERE module_id = $1 AND ward_no = $2`
	err := DB.QueryRow(query, moduleID, wardNo).Scan(&officerID)
	if err == sql.ErrNoRows {
		return 0, nil
	}
	return officerID, err
}

// ============================================
// COMPLAINT QUERIES
// ============================================

func CreateComplaint(complaint *models.Complaint) error {
	query := `INSERT INTO complaints
              (complaint_id, user_phone, module_id, ward_no, assigned_officer_id,
               location, latitude, longitude, complaint_photo, reason, status)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'PENDING')
              RETURNING created_at, updated_at`

	err := DB.QueryRow(
		query,
		complaint.ComplaintID,
		complaint.UserPhone,
		complaint.ModuleID,
		complaint.WardNo,
		complaint.AssignedOfficerID,
		complaint.Location,
		complaint.Latitude,
		complaint.Longitude,
		complaint.ComplaintPhoto,
		complaint.Reason,
	).Scan(&complaint.CreatedAt, &complaint.UpdatedAt)

	return err
}

func GetComplaintsByCitizen(userID int) ([]models.Complaint, error) {
	query := `SELECT c.complaint_id, c.user_phone, c.module_id, c.ward_no, c.assigned_officer_id,
                     c.location, c.latitude, c.longitude, COALESCE(c.complaint_photo, '') as complaint_photo,
                     COALESCE(c.reason, '') as reason, c.status, c.created_at, c.updated_at
              FROM complaints c
              JOIN users u ON c.user_phone = u.phone_number
              WHERE u.user_id = $1 ORDER BY c.created_at DESC`
	rows, err := DB.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var complaints []models.Complaint
	for rows.Next() {
		var c models.Complaint
		err := rows.Scan(
			&c.ComplaintID, &c.UserPhone, &c.ModuleID, &c.WardNo, &c.AssignedOfficerID,
			&c.Location, &c.Latitude, &c.Longitude, &c.ComplaintPhoto, &c.Reason, &c.Status, &c.CreatedAt, &c.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		// Split location formatted as "street|area|city|description"
		parts := strings.Split(c.Location, "|")
		if len(parts) >= 4 {
			c.Street = parts[0]
			c.Area = parts[1]
			c.City = parts[2]
			c.Description = parts[3]
		} else {
			c.Street = c.Location
		}
		complaints = append(complaints, c)
	}
	return complaints, nil
}

func UpdateWorkOrderStatus(complaintID uuid.UUID, status, remarks string) error {
	var oldStatus string
	var officerID int
	err := DB.QueryRow(`SELECT status, assigned_officer_id FROM complaints WHERE complaint_id = $1`, complaintID).Scan(&oldStatus, &officerID)
	if err != nil {
		return err
	}

	var newDBStatus string
	switch strings.ToLower(status) {
	case "completed":
		newDBStatus = "COMPLETED"
	case "rejected":
		newDBStatus = "REJECTED"
	case "accepted":
		newDBStatus = "ACCEPTED"
	case "in_progress":
		newDBStatus = "IN_PROGRESS"
	default:
		newDBStatus = "PENDING"
	}

	tx, err := DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	_, err = tx.Exec(`UPDATE complaints SET status = $1, updated_at = NOW() WHERE complaint_id = $2`, newDBStatus, complaintID)
	if err != nil {
		return err
	}

	_, err = tx.Exec(`INSERT INTO complaint_updates (complaint_id, officer_id, old_status, new_status, remarks)
                      VALUES ($1, $2, $3, $4, $5)`, complaintID, officerID, oldStatus, newDBStatus, remarks)
	if err != nil {
		return err
	}

	return tx.Commit()
}

// ============================================
// WORK ORDER QUERIES
// ============================================

func GetWorkOrdersByOfficer(officerID int) ([]models.WorkOrder, error) {
	query := `SELECT complaint_id, location, COALESCE(reason, '') as reason, status, created_at
              FROM complaints WHERE assigned_officer_id = $1 ORDER BY created_at DESC`
	rows, err := DB.Query(query, officerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []models.WorkOrder
	for rows.Next() {
		var c struct {
			ComplaintID uuid.UUID
			Location    string
			Reason      string
			Status      string
			CreatedAt   time.Time
		}
		if err := rows.Scan(&c.ComplaintID, &c.Location, &c.Reason, &c.Status, &c.CreatedAt); err != nil {
			return nil, err
		}

		parts := strings.Split(c.Location, "|")
		description := ""
		title := c.Reason
		if len(parts) >= 4 {
			description = parts[3]
		} else {
			description = c.Location
		}

		// Map to lowercase status for frontend compatibility (todo, completed, rejected)
		statusMapped := "todo"
		dbStatus := strings.ToUpper(c.Status)
		if dbStatus == "COMPLETED" {
			statusMapped = "completed"
		} else if dbStatus == "REJECTED" {
			statusMapped = "rejected"
		}

		wo := models.WorkOrder{
			WorkOrderID: c.ComplaintID,
			ComplaintID: c.ComplaintID,
			OfficerID:   officerID,
			Title:       title,
			Description: description,
			Priority:    "medium",
			Status:      statusMapped,
			AssignedAt:  c.CreatedAt,
		}
		orders = append(orders, wo)
	}
	return orders, nil
}

// ============================================
// MODULE QUERIES
// ============================================

func GetModules() ([]models.Module, error) {
	rows, err := DB.Query(`SELECT module_id, module_name FROM modules ORDER BY module_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var modules []models.Module
	for rows.Next() {
		var m models.Module
		err := rows.Scan(&m.ModuleID, &m.ModuleName)
		if err != nil {
			return nil, err
		}
		modules = append(modules, m)
	}
	return modules, nil
}