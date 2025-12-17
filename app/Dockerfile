# Build stage: Compile Go application
# Uses golang:1.21-alpine as builder to keep dependencies clean
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Copy source code into builder
COPY main.go .

# Initialize Go module and compile binary
# CGO_ENABLED=0: Disables C dependencies for maximum portability
# GOOS=linux: Compiles for Linux target
# -a: Forces rebuild of all dependencies
# -installsuffix cgo: Adds suffix to installed packages (optimization)
# Result: Single statically-linked binary (~7-10MB)
RUN go mod init simpletimeservice && \ 
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o simpletimeservice main.go

# Final stage: Minimal runtime image
# Uses alpine:3.18 for minimal size (~5MB)
# This stage runs the compiled binary from the builder stage
# Final image size: ~15MB (Alpine + binary + SSL certificates)
FROM alpine:3.18

# Install only necessary runtime dependencies
# ca-certificates: Required for HTTPS/TLS connections
# --no-cache: Prevents storing package manager cache (saves space)
RUN apk --no-cache add ca-certificates

# Create non-root user for security (best practice)
# addgroup: Creates new user group "appgroup"
# adduser: Creates user "appuser" with -S flag (system user, no login shell)
# -G: Assigns user to the group
# This prevents container escape exploits from gaining root access
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy compiled binary from builder stage
# --from=builder: References the builder stage
# Only copies the ~7-10MB binary, not the entire Go compiler (~600MB)
# This is why multi-stage builds are essential for small images
COPY --from=builder /build/simpletimeservice .

# Set correct file ownership for non-root user
# This allows appuser to read and execute the binary
RUN chown -R appuser:appgroup /app

# Switch to non-root user for all subsequent commands and runtime
USER appuser

# Expose port (documentation only, doesn't actually publish the port)
# Use -p flag when running: docker run -p 8080:8080
EXPOSE 8080

# Docker health check for container orchestration systems
# Periodically verifies the service is responding correctly
# interval=30s: Check every 30 seconds
# timeout=3s: Wait up to 3 seconds for response
# start-period=5s: Wait 5 seconds before first check (startup grace period)
# retries=3: Mark unhealthy after 3 consecutive failures
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
# Executes as 'appuser' (non-root) due to USER directive above
# Process runs as PID 1 inside the container
CMD ["./simpletimeservice"]
