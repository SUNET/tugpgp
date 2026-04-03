# Tugpgp - OpenPGP Key Generation and Yubikey Upload Tool
# Run `just --list` to see available targets

# Default target
default:
    @just --list

# Run development server
dev:
    pnpm tauri dev

# Build production app (all formats)
build:
    pnpm tauri build

# Build only the frontend
build-frontend:
    pnpm build

# Install frontend dependencies
install:
    pnpm install

# Clean build artifacts
clean:
    rm -rf dist
    rm -rf src-tauri/target
    rm -rf node_modules

# Clean only dist directory (package outputs)
clean-dist:
    rm -rf dist

# Clean only Rust build artifacts
clean-rust:
    rm -rf src-tauri/target

# Generate app icons from SVG source
icons:
    #!/usr/bin/env bash
    SVG="src/assets/icons/tugpgp-icon.svg"
    ICONS="src-tauri/icons"
    convert -background transparent "$SVG" -resize 32x32 "PNG32:$ICONS/32x32.png"
    convert -background transparent "$SVG" -resize 128x128 "PNG32:$ICONS/128x128.png"
    convert -background transparent "$SVG" -resize 256x256 "PNG32:$ICONS/128x128@2x.png"
    convert -background transparent "$SVG" -resize 512x512 "PNG32:$ICONS/icon.png"
    echo "Icons generated in $ICONS/"

# Convert semver prerelease to RPM-compatible version
# 0.3.0-alpha.1 -> 0.3.0~alpha.1 (sorts before 0.3.0)
_rpm-version:
    #!/usr/bin/env bash
    VERSION=$(grep '"version"' src-tauri/tauri.conf.json | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
    # Convert - to ~ for proper RPM sorting of prereleases
    echo "${VERSION//-/\~}"

# Convert semver prerelease to DEB-compatible version
# 0.3.0-alpha.1 -> 0.3.0~alpha.1 (sorts before 0.3.0)
_deb-version:
    #!/usr/bin/env bash
    VERSION=$(grep '"version"' src-tauri/tauri.conf.json | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
    # Convert - to ~ for proper Debian sorting of prereleases
    echo "${VERSION//-/\~}"

# Build RPM package using Docker
# Usage: just build-rpm [base_image]
# Examples:
#   just build-rpm              # Uses fedora:43 (default)
#   just build-rpm fedora:42
#   just build-rpm fedora:41
# Note: Version 0.3.0-alpha.1 is converted to 0.3.0~alpha.1 for proper RPM sorting
build-rpm base_image="fedora:43":
    #!/usr/bin/env bash
    set -e
    BASE_IMAGE="{{base_image}}"
    # Extract distro name for output directory (e.g., fedora-43)
    DISTRO_NAME=$(echo "$BASE_IMAGE" | tr ':' '-')
    OUTPUT_DIR="dist/$DISTRO_NAME"

    # Get RPM-compatible version (convert - to ~ for prereleases)
    SEMVER=$(grep '"version"' src-tauri/tauri.conf.json | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
    RPM_VERSION="${SEMVER//-/\~}"

    echo "Building RPM for $BASE_IMAGE..."
    echo "Semver: $SEMVER -> RPM version: $RPM_VERSION"
    mkdir -p "$OUTPUT_DIR"

    docker build \
        --build-arg BASE_IMAGE="$BASE_IMAGE" \
        --build-arg PKG_VERSION="$RPM_VERSION" \
        -f Dockerfile.rpm \
        -t "tugpgp-rpm-$DISTRO_NAME" \
        .

    CONTAINER_ID=$(docker create "tugpgp-rpm-$DISTRO_NAME")
    docker cp "$CONTAINER_ID:/app/src-tauri/target/release/bundle/rpm/." "$OUTPUT_DIR/"
    docker rm "$CONTAINER_ID"

    echo ""
    echo "RPM package(s) for $BASE_IMAGE available in $OUTPUT_DIR/"
    ls -la "$OUTPUT_DIR/"*.rpm 2>/dev/null || echo "No RPM files found"

# Build DEB package using Docker
# Usage: just build-deb [base_image]
# Examples:
#   just build-deb                  # Uses debian:13 (default)
#   just build-deb debian:12
#   just build-deb ubuntu:24.04
#   just build-deb ubuntu:22.04
# Note: Version 0.3.0-alpha.1 is converted to 0.3.0~alpha.1 for proper Debian sorting
build-deb base_image="debian:13":
    #!/usr/bin/env bash
    set -e
    BASE_IMAGE="{{base_image}}"
    # Extract distro name for output directory (e.g., debian-13, ubuntu-24.04)
    DISTRO_NAME=$(echo "$BASE_IMAGE" | tr ':' '-')
    OUTPUT_DIR="dist/$DISTRO_NAME"

    # Get DEB-compatible version (convert - to ~ for prereleases)
    SEMVER=$(grep '"version"' src-tauri/tauri.conf.json | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
    DEB_VERSION="${SEMVER//-/\~}"

    echo "Building DEB for $BASE_IMAGE..."
    echo "Semver: $SEMVER -> DEB version: $DEB_VERSION"
    mkdir -p "$OUTPUT_DIR"

    docker build \
        --build-arg BASE_IMAGE="$BASE_IMAGE" \
        --build-arg PKG_VERSION="$DEB_VERSION" \
        -f Dockerfile.deb \
        -t "tugpgp-deb-$DISTRO_NAME" \
        .

    CONTAINER_ID=$(docker create "tugpgp-deb-$DISTRO_NAME")
    docker cp "$CONTAINER_ID:/app/src-tauri/target/release/bundle/deb/." "$OUTPUT_DIR/"
    docker rm "$CONTAINER_ID"

    echo ""
    echo "DEB package(s) for $BASE_IMAGE available in $OUTPUT_DIR/"
    ls -la "$OUTPUT_DIR/"*.deb 2>/dev/null || echo "No DEB files found"

# Build AppImage
build-appimage:
    pnpm tauri build --bundles appimage

# Build all packages for multiple distributions
build-all-rpm:
    just build-rpm fedora:43
    just build-rpm fedora:42

build-all-deb:
    just build-deb debian:13
    just build-deb debian:12
    just build-deb ubuntu:24.04
    just build-deb ubuntu:22.04

# Lint frontend code
lint:
    pnpm exec eslint src/

# Format frontend code
format:
    pnpm exec prettier --write src/

# Check Rust code
check-rust:
    cd src-tauri && cargo check

# Format Rust code
format-rust:
    cd src-tauri && cargo fmt

# Lint Rust code
lint-rust:
    cd src-tauri && cargo clippy

# Run all checks
check: check-rust lint

# Format all code
format-all: format format-rust

# Show project info
info:
    @echo "Tugpgp - OpenPGP Key Generation and Yubikey Upload Tool"
    @echo ""
    @echo "Frontend: Vue 3 + Vite"
    @echo "Backend: Tauri 2 (Rust)"
    @echo ""
    @echo "Node version: $(node --version)"
    @echo "pnpm version: $(pnpm --version)"
    @echo "Rust version: $(rustc --version)"
    @echo "Cargo version: $(cargo --version)"

# Build macOS DMG (unsigned)
build-dmg:
    pnpm tauri build --bundles dmg

# Build macOS DMG with signing and notarization
# Required environment variables:
#   APPLE_SIGNING_IDENTITY - Certificate identity (e.g., "Developer ID Application: Name (TEAM_ID)")
#   APPLE_ID               - Apple ID email for notarization
#   APPLE_PASSWORD         - App-specific password (generate at appleid.apple.com)
#   APPLE_TEAM_ID          - Your Apple Developer Team ID
#
# Optional (alternative to APPLE_ID/PASSWORD):
#   APPLE_API_KEY          - Path to AuthKey_XXXXX.p8 file
#   APPLE_API_ISSUER       - API issuer ID from App Store Connect
#   APPLE_API_KEY_ID       - API key ID
build-dmg-signed:
    #!/usr/bin/env bash
    set -e

    # Verify required environment variables
    if [ -z "$APPLE_SIGNING_IDENTITY" ]; then
        echo "Error: APPLE_SIGNING_IDENTITY not set"
        echo "Example: export APPLE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAM_ID)'"
        exit 1
    fi

    if [ -z "$APPLE_TEAM_ID" ]; then
        echo "Error: APPLE_TEAM_ID not set"
        exit 1
    fi

    # Check for either password-based or API key-based notarization
    if [ -z "$APPLE_API_KEY" ]; then
        if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ]; then
            echo "Error: For notarization, set either:"
            echo "  - APPLE_ID and APPLE_PASSWORD (app-specific password)"
            echo "  - Or APPLE_API_KEY, APPLE_API_ISSUER, and APPLE_API_KEY_ID"
            exit 1
        fi
    fi

    echo "Building signed macOS DMG..."
    echo "Signing identity: $APPLE_SIGNING_IDENTITY"
    echo "Team ID: $APPLE_TEAM_ID"

    pnpm tauri build --bundles dmg

    echo ""
    echo "DMG built and signed. Output in src-tauri/target/release/bundle/dmg/"
    ls -la src-tauri/target/release/bundle/dmg/*.dmg 2>/dev/null || echo "No DMG files found"

# List available build targets
list-targets:
    @echo "RPM targets (Fedora):"
    @echo "  just build-rpm fedora:43  (default)"
    @echo "  just build-rpm fedora:42"
    @echo "  just build-rpm fedora:41"
    @echo ""
    @echo "DEB targets (Debian/Ubuntu):"
    @echo "  just build-deb debian:13  (default)"
    @echo "  just build-deb debian:12"
    @echo "  just build-deb ubuntu:24.04"
    @echo "  just build-deb ubuntu:22.04"
    @echo ""
    @echo "macOS targets:"
    @echo "  just build-dmg           (unsigned)"
    @echo "  just build-dmg-signed    (signed + notarized, requires Apple Developer credentials)"
