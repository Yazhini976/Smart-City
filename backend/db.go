package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

var DB *sql.DB

// Fill these in (or read from env vars) to match your Postgres install.
const (
	dbHost     = "localhost"
	dbPort     = 5432
	dbUser     = "postgres"
	dbPassword = "shri23"
	dbName     = "smartcity"
)

func connectDB() {
	connStr := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName,
	)

	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("failed to open db: %v", err)
	}

	if err = DB.Ping(); err != nil {
		log.Fatalf("failed to connect to db: %v (is Postgres running, and does the '%s' database exist?)", err, dbName)
	}

	log.Println("connected to Postgres database:", dbName)
}
