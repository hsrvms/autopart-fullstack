package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/hsrvms/autoparts/internal/server"
	"github.com/hsrvms/autoparts/pkg/config"
	"github.com/hsrvms/autoparts/pkg/db"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables from .env.production file if it exists
	envFile := ".env.production"
	if _, err := os.Stat(envFile); err == nil {
		if err := godotenv.Load(envFile); err != nil {
			log.Printf("Warning: Error loading %s file: %v", envFile, err)
		} else {
			log.Printf("Loaded environment from %s", envFile)
		}
	} else {
		// Try to load from the executable directory
		execPath, err := os.Executable()
		if err == nil {
			execDir := filepath.Dir(execPath)
			envPath := filepath.Join(execDir, envFile)
			if _, err := os.Stat(envPath); err == nil {
				if err := godotenv.Load(envPath); err != nil {
					log.Printf("Warning: Error loading %s file: %v", envPath, err)
				} else {
					log.Printf("Loaded environment from %s", envPath)
				}
			}
		}
	}

	cfg := config.New()

	database, err := db.New(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer database.Close()

	srv := server.New(cfg, database)
	srv.Start()
}
