package main

import (
    "log"
    "os"

    "github.com/gin-gonic/gin"
    "github.com/joho/godotenv"

    "smartcity/db"
    "smartcity/handlers"
    "smartcity/middleware"
)

func main() {
    // Load .env
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found")
    }

    // Initialize DB
    db.InitDB()

    // Load wards from JSON
    handlers.LoadWards()

    r := gin.Default()

    // CORS
    r.Use(func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        c.Next()
    })

    // Public routes (NO AUTH)
    r.POST("/api/auth/send-otp", handlers.SendOTP)
    r.POST("/api/auth/verify-otp", handlers.VerifyOTP)
    r.GET("/api/modules", handlers.GetModules)  // ← MOVED TO PUBLIC
    r.GET("/api/wards/lookup", handlers.LookupWard)

    // Protected routes (WITH AUTH)
    api := r.Group("/api")
    api.Use(middleware.Auth())
    {
        api.POST("/complaints", handlers.CreateComplaint)
        api.GET("/complaints", handlers.GetUserComplaints)
        api.GET("/officer/work-orders", handlers.GetOfficerWorkOrders)
        api.PUT("/work-orders/:id", handlers.UpdateWorkOrder)
        api.POST("/auth/update-role", handlers.UpdateUserRole)
    }

    port := os.Getenv("PORT")
    if port == "" {
        port = "8081"
    }

    log.Printf("Server starting on port %s", port)
    r.Run(":" + port)
}