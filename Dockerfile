# Build stage
FROM rust:slim-bullseye as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a new empty project
WORKDIR /usr/src/steamguard-cli

# Copy manifests first to cache dependencies
COPY Cargo.toml Cargo.lock ./
COPY steamguard/Cargo.toml ./steamguard/

# Create dummy source files to build dependencies
RUN mkdir -p src && \
    mkdir -p steamguard/src && \
    echo "fn main() {}" > src/main.rs && \
    touch steamguard/src/lib.rs && \
    cargo build --release && \
    rm -rf src steamguard/src

# Copy the actual source code
COPY src ./src
COPY steamguard ./steamguard

# Build the application with all features
RUN cargo build --release

# Runtime stage
FROM debian:bullseye-slim

# Install runtime dependencies and a lightweight web server
RUN apt-get update && \
    apt-get install -y ca-certificates libssl1.1 python3 python3-pip && \
    pip3 install flask gunicorn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /usr/src/steamguard-cli/target/release/steamguard /usr/local/bin/steamguard

# Copy web interface files
COPY webui /app/webui

# Create a volume to store maFile configurations
VOLUME /root/.config/steamguard-cli/maFiles

# Expose port for web interface
EXPOSE 8080

# Start script that runs both the web UI and provides access to the CLI
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
