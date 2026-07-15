package models

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	UserID      int       `json:"user_id"`
	PhoneNumber string    `json:"phone_number"`
	Name        string    `json:"name"`
	CreatedAt   time.Time `json:"created_at"`
}

type Module struct {
	ModuleID   int    `json:"module_id"`
	ModuleName string `json:"module_name"`
}

type FieldOfficer struct {
	OfficerID   int       `json:"officer_id"`
	ModuleID    int       `json:"module_id"`
	OfficerName string    `json:"officer_name"`
	PhoneNumber string    `json:"phone_number"`
	WardFrom    int       `json:"ward_from"`
	WardTo      int       `json:"ward_to"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
}

type WardMapping struct {
	MappingID int `json:"mapping_id"`
	ModuleID  int `json:"module_id"`
	WardNo    int `json:"ward_no"`
	OfficerID int `json:"officer_id"`
}

type Complaint struct {
	ComplaintID       uuid.UUID `json:"complaint_id"`
	UserPhone         string    `json:"user_phone"`
	ModuleID          int       `json:"module_id"`
	WardNo            int       `json:"ward_no"`
	AssignedOfficerID *int      `json:"assigned_officer_id"` // Pointer for nullable INT
	Location          string    `json:"location"`           // Serialized as: "street|area|city|description"
	Latitude          float64   `json:"latitude"`
	Longitude         float64   `json:"longitude"`
	ComplaintPhoto    string    `json:"photo_url"` // Maps to complaint_photo in DB, photo_url in Flutter
	Reason            string    `json:"title"`     // Maps to reason in DB, title in Flutter
	Severity          string    `json:"severity"`
	AIDetectedIssue   string    `json:"ai_detected_issue"`
	AIConfidence      float64   `json:"ai_confidence"`
	Status            string    `json:"status"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// Split helper fields for JSON API response
	Street      string `json:"street"`
	Area        string `json:"area"`
	City        string `json:"city"`
	Description string `json:"description"`
}

type WorkOrder struct {
	WorkOrderID     uuid.UUID  `json:"work_order_id"`
	ComplaintID     uuid.UUID  `json:"complaint_id"`
	OfficerID       int        `json:"officer_id"`
	Title           string     `json:"title"`
	Description     string     `json:"description"`
	Priority        string     `json:"priority"`
	Status          string     `json:"status"`
	RejectionReason *string    `json:"rejection_reason"` // Nullable
	AssignedAt      time.Time  `json:"assigned_at"`
	CompletedAt     *time.Time `json:"completed_at"`
}

type LoginRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
}

type OTPRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	OTP         string `json:"otp" binding:"required"`
}

type ComplaintRequest struct {
	ModuleID    int     `json:"module_id" binding:"required"`
	Latitude    float64 `json:"latitude" binding:"required"`
	Longitude   float64 `json:"longitude" binding:"required"`
	Street      string  `json:"street"`
	Area        string  `json:"area"`
	City        string  `json:"city"`
	Title       string  `json:"title" binding:"required"` // Maps to reason
	Description string  `json:"description" binding:"required"`
	PhotoURL    string  `json:"photo_url"`
}

type WorkOrderUpdate struct {
	Status  string `json:"status"`
	Remarks string `json:"remarks"`
}

type RoleUpdateRequest struct {
	Role string `json:"role" binding:"required,oneof=citizen officer"`
}