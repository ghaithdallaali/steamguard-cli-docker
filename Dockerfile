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

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates libssl1.1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /usr/src/steamguard-cli/target/release/steamguard /usr/local/bin/steamguard

# Create a volume for configuration
VOLUME /root/.config/steamguard-cli

# Set the entrypoint
ENTRYPOINT ["steamguard"]
# Default command (can be overridden)
CMD ["--help"]
