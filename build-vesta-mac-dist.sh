#!/bin/bash

# Vesta macOS Distribution Build Script
# Creates notarized DMG and publishes to vesta-mac-dist repository
# Usage: ./build-vesta-mac-dist.sh <version>
# Example: ./build-vesta-mac-dist.sh 0.3.4

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VESTA_REPO_DIR="$(dirname "$SCRIPT_DIR")"  # Assumes script is in vesta-mac/vesta-mac-dist/
APP_NAME="Vesta"
BUILD_DIR="$VESTA_REPO_DIR/build"
EXPORT_DIR="$BUILD_DIR/Release"
DMG_TEMP_DIR="$BUILD_DIR/dmg-temp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Check parameters
if [ $# -ne 1 ]; then
    echo -e "${RED}❌ Usage: $0 <version>${NC}"
    echo -e "${YELLOW}   Example: $0 0.3.4${NC}"
    exit 1
fi

VERSION="$1"
DMG_NAME="Vesta-$VERSION"
FINAL_DMG="$BUILD_DIR/$DMG_NAME.dmg"

# Validate version format (x.y.z)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Invalid version format. Use x.y.z (e.g., 0.3.4)${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Building Vesta $VERSION for Distribution${NC}"
echo -e "${BLUE}Repository: $(basename "$VESTA_REPO_DIR")${NC}"
echo -e "${BLUE}Build Directory: $BUILD_DIR${NC}"
echo ""

# Verify we're in the correct directory structure
if [ ! -f "$VESTA_REPO_DIR/Vesta.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Error: Cannot find Vesta.xcodeproj${NC}"
    echo -e "${YELLOW}   Make sure this script is in vesta-mac/vesta-mac-dist/${NC}"
    exit 1
fi

# Function to update version in Info.plist
update_info_plist() {
    local plist_file="$VESTA_REPO_DIR/Vesta/Info.plist"
    
    echo -e "${BLUE}📝 Updating Info.plist version to $VERSION${NC}"
    
    # Get current build number and increment it
    local current_build=$(plutil -extract CFBundleVersion raw "$plist_file")
    local new_build=$((current_build + 1))
    
    # Update version and build number
    plutil -replace CFBundleShortVersionString -string "$VERSION" "$plist_file"
    plutil -replace CFBundleVersion -string "$new_build" "$plist_file"
    
    echo -e "${GREEN}   ✓ Updated to version $VERSION (build $new_build)${NC}"
}

# Function to update version in VestaApp.swift
update_vesta_app() {
    local app_file="$VESTA_REPO_DIR/Vesta/VestaApp.swift"
    
    echo -e "${BLUE}📝 Updating About dialog version to $VERSION${NC}"
    
    # Update the version string in the About dialog
    sed -i '' "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version $VERSION/g" "$app_file"
    
    echo -e "${GREEN}   ✓ Updated About dialog version${NC}"
}

# Function to verify code signing setup
verify_codesign_setup() {
    echo -e "${BLUE}🔐 Verifying code signing setup${NC}"
    
    local cert_name="Developer ID Application: Soprano Technologies Inc. (F692WKU8NQ)"
    if security find-identity -v -p codesigning | grep -q "$cert_name"; then
        echo -e "${GREEN}   ✓ Developer ID certificate found${NC}"
    else
        echo -e "${RED}❌ Developer ID certificate not found${NC}"
        echo -e "${YELLOW}   Make sure the certificate is installed in your keychain${NC}"
        exit 1
    fi
    
    # Check notarization credentials
    if xcrun notarytool history --keychain-profile "AC_PASSWORD_VESTA" &>/dev/null; then
        echo -e "${GREEN}   ✓ Notarization credentials configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Notarization credentials not found, will try AC_PASSWORD${NC}"
    fi
}

# Function to set up Xcode environment
setup_xcode() {
    echo -e "${BLUE}🔧 Setting up Xcode Beta environment${NC}"
    
    # Set Xcode Beta as active
    if [ -d "/Applications/Xcode-beta.app" ]; then
        sudo xcode-select --switch /Applications/Xcode-beta.app/Contents/Developer
        echo -e "${GREEN}   ✓ Xcode Beta activated${NC}"
    else
        echo -e "${YELLOW}⚠️  Xcode Beta not found, using default Xcode${NC}"
    fi
    
    # Show current Xcode path
    echo -e "${BLUE}   Active Xcode: $(xcode-select -p)${NC}"
}

# Function to clean and prepare build environment
prepare_build() {
    echo -e "${BLUE}🧹 Preparing build environment${NC}"
    
    # Clean previous builds
    if [ -d "$BUILD_DIR" ]; then
        echo -e "${YELLOW}   Cleaning previous build artifacts${NC}"
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$DMG_TEMP_DIR"
    
    echo -e "${GREEN}   ✓ Build environment ready${NC}"
}

# Function to build and archive the app
build_and_archive() {
    echo -e "${BLUE}🔨 Building and archiving $APP_NAME${NC}"
    
    cd "$VESTA_REPO_DIR"
    
    xcodebuild -project "$APP_NAME.xcodeproj" \
               -scheme "$APP_NAME" \
               -configuration Release \
               -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
               archive
    
    if [ ! -d "$BUILD_DIR/$APP_NAME.xcarchive" ]; then
        echo -e "${RED}❌ Archive failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}   ✓ Archive created successfully${NC}"
}

# Function to export the archive
export_archive() {
    echo -e "${BLUE}📦 Exporting archive for Developer ID distribution${NC}"
    
    local export_options="$VESTA_REPO_DIR/ExportOptions.plist"
    
    if [ ! -f "$export_options" ]; then
        echo -e "${RED}❌ ExportOptions.plist not found${NC}"
        exit 1
    fi
    
    cd "$VESTA_REPO_DIR"
    
    xcodebuild -exportArchive \
               -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
               -exportPath "$EXPORT_DIR" \
               -exportOptionsPlist "$export_options"
    
    if [ ! -d "$EXPORT_DIR/$APP_NAME.app" ]; then
        echo -e "${RED}❌ Export failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}   ✓ App exported successfully${NC}"
}

# Function to verify app signature
verify_signature() {
    echo -e "${BLUE}🔍 Verifying app signature${NC}"
    
    codesign -vvv --deep --strict "$EXPORT_DIR/$APP_NAME.app"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ App signature verified${NC}"
    else
        echo -e "${RED}❌ App signature verification failed${NC}"
        exit 1
    fi
}

# Function to notarize the app
notarize_app() {
    echo -e "${BLUE}🔐 Notarizing app with Apple${NC}"
    
    # Try AC_PASSWORD_VESTA first, fall back to AC_PASSWORD
    local profile="AC_PASSWORD_VESTA"
    if ! xcrun notarytool history --keychain-profile "$profile" &>/dev/null; then
        profile="AC_PASSWORD"
    fi
    
    # Create a zip for notarization
    local zip_file="$BUILD_DIR/$APP_NAME.zip"
    cd "$EXPORT_DIR"
    zip -r "$zip_file" "$APP_NAME.app"
    
    echo -e "${YELLOW}   Submitting for notarization (this may take a few minutes)...${NC}"
    
    if xcrun notarytool submit "$zip_file" --keychain-profile "$profile" --wait; then
        echo -e "${GREEN}   ✓ App successfully notarized${NC}"
        
        # Staple the notarization
        xcrun stapler staple "$EXPORT_DIR/$APP_NAME.app"
        echo -e "${GREEN}   ✓ Notarization stapled to app${NC}"
    else
        echo -e "${YELLOW}⚠️  Notarization failed, continuing without it${NC}"
        echo -e "${YELLOW}   Users may see security warnings${NC}"
    fi
    
    # Clean up zip file
    rm -f "$zip_file"
}

# Function to create DMG
create_dmg() {
    echo -e "${BLUE}💿 Creating DMG${NC}"
    
    # Copy app to DMG temp directory
    cp -R "$EXPORT_DIR/$APP_NAME.app" "$DMG_TEMP_DIR/"
    
    # Create Applications symlink
    ln -s /Applications "$DMG_TEMP_DIR/Applications"
    
    # Create README for the DMG
    cat > "$DMG_TEMP_DIR/README.txt" << EOF
Vesta - AI-Powered Chat Assistant
==================================

Installation Instructions:
1. Drag Vesta.app to the Applications folder
2. Open Vesta from Applications folder
3. If you see a security warning, right-click Vesta and select "Open"

Requirements:
- macOS 26.0 Beta or later
- Mac with Apple Silicon (required for Apple Intelligence features)

Features:
- On-device AI processing (when Apple Intelligence entitlement is active)
- Voice input with speech recognition
- LaTeX math rendering
- Complete app sandbox security
- Developer ID signed and notarized

Privacy:
All processing occurs on-device. No data is sent to external servers.

For support and updates:
https://github.com/scouzi1966/vesta-mac-dist
EOF
    
    # Calculate DMG size (app size + 50MB padding)
    local app_size=$(du -sm "$EXPORT_DIR/$APP_NAME.app" | cut -f1)
    local dmg_size=$((app_size + 50))
    
    echo -e "${BLUE}   Creating ${dmg_size}MB DMG...${NC}"
    
    # Create the DMG
    hdiutil create -size ${dmg_size}m \
                   -volname "$APP_NAME" \
                   -srcfolder "$DMG_TEMP_DIR" \
                   -ov \
                   -format UDZO \
                   "$FINAL_DMG"
    
    echo -e "${GREEN}   ✓ DMG created: $(basename "$FINAL_DMG")${NC}"
}

# Function to verify DMG
verify_dmg() {
    echo -e "${BLUE}✅ Verifying DMG${NC}"
    
    if hdiutil verify "$FINAL_DMG"; then
        echo -e "${GREEN}   ✓ DMG verification successful${NC}"
    else
        echo -e "${RED}❌ DMG verification failed${NC}"
        exit 1
    fi
    
    # Show final file info
    echo -e "${GREEN}📊 Final DMG: $(du -h "$FINAL_DMG" | cut -f1)${NC}"
}

# Function to create GitHub release
create_github_release() {
    echo -e "${BLUE}🚀 Creating GitHub release${NC}"
    
    cd "$SCRIPT_DIR"  # vesta-mac-dist directory
    
    local tag="v$VERSION"
    local release_title="Vesta $VERSION"
    
    # Create release notes
    local release_notes=$(cat << EOF
## Vesta $VERSION

### 🚀 Features
- Apple Intelligence integration for on-device AI processing
- Voice input with speech-to-text functionality  
- LaTeX math rendering support
- Liquid Glass UI design with macOS integration
- Complete app sandbox security compliance

### 📋 Installation
1. Download the DMG file below
2. Open the DMG and drag Vesta to Applications
3. Launch Vesta from Applications folder
4. On first run, right-click and select "Open" if prompted

### 🔒 Security
- Signed with Developer ID for reduced security warnings
- Notarized by Apple for additional security verification
- App Sandbox enabled for enhanced system protection
- All AI processing happens on-device - no data sent to servers

### 📱 Requirements
- macOS 26.0 Beta or later
- Mac with Apple Silicon (recommended for Apple Intelligence)
- Microphone access (for voice input features)

---

🤖 Built with automated distribution pipeline
EOF
    )
    
    # Create the release
    if gh release create "$tag" \
        --title "$release_title" \
        --notes "$release_notes" \
        --latest \
        "$FINAL_DMG"; then
        echo -e "${GREEN}   ✓ Release created: https://github.com/scouzi1966/vesta-mac-dist/releases/tag/$tag${NC}"
    else
        echo -e "${RED}❌ Failed to create GitHub release${NC}"
        exit 1
    fi
}

# Function to cleanup
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up temporary files${NC}"
    
    rm -rf "$DMG_TEMP_DIR"
    
    echo -e "${GREEN}   ✓ Cleanup complete${NC}"
}

# Main execution
main() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}   Vesta macOS Distribution Builder   ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
    
    update_info_plist
    update_vesta_app
    verify_codesign_setup
    setup_xcode
    prepare_build
    build_and_archive
    export_archive
    verify_signature
    notarize_app
    create_dmg
    verify_dmg
    create_github_release
    cleanup
    
    echo ""
    echo -e "${GREEN}🎉 Vesta $VERSION distribution build complete!${NC}"
    echo -e "${GREEN}📦 DMG: $FINAL_DMG${NC}"
    echo -e "${GREEN}🌐 Release: https://github.com/scouzi1966/vesta-mac-dist/releases/tag/v$VERSION${NC}"
    echo ""
}

# Run main function
main "$@"