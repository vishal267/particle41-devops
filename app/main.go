// Package main provides a lightweight microservice that returns current timestamp and visitor IP.
//
// The service exposes two HTTP endpoints:
// - GET /      Returns current time and visitor IP in JSON format
// - GET /health Health check endpoint for monitoring systems
//
// The application runs on port 8080 and executes as a non-root user for security.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

// TimeResponse represents the JSON response structure returned by the / endpoint.
// It contains the current timestamp in ISO 8601 format and the visitor's IP address.
type TimeResponse struct {
	// Timestamp is the current date and time in RFC3339 format (ISO 8601)
	// Example: "2025-12-17T14:32:45Z"
	Timestamp string `json:"timestamp"`

	// IP is the IP address of the HTTP client making the request.
	// If behind a proxy, reads from X-Forwarded-For header; otherwise uses RemoteAddr.
	// Example: "192.168.1.100" or "203.0.113.45"
	IP string `json:"ip"`
}

// healthHandler handles GET /health requests.
// Returns a simple JSON response indicating the service is healthy.
// Used by Docker/Kubernetes health checks to verify service availability.
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	health := map[string]string{"status": "healthy"}
	json.NewEncoder(w).Encode(health)
}

func timeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	// Get visitor IP address
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip = r.RemoteAddr
	}
	
	// Get current time in ISO 8601 format
	currentTime := time.Now().Format(time.RFC3339)
	
	response := TimeResponse{
		Timestamp: currentTime,
		IP:        ip,
	}
	
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/", timeHandler)
	http.HandleFunc("/health", healthHandler)
	
	port := ":8080"
	log.Printf("SimpleTimeService started on http://0.0.0.0%s", port)
	log.Printf("Access / for current time in JSON format")
	log.Printf("Access /health for health check")
	
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
