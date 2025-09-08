# Vesta macOS Distribution

Official distribution repository for Vesta - AI-powered chat assistant with Apple Intelligence integration.

## 📥 Download

**[⬇️ Download Latest Release](https://github.com/scouzi1966/vesta-mac-dist/releases/latest)**

All releases are code-signed with Developer ID and notarized by Apple for security.

## 🚀 Features

- **Apple Intelligence Integration** - On-device AI processing with Apple's Foundation Models framework
- **Voice Input** - Speech-to-text functionality for natural interaction
- **LaTeX Math Rendering** - Support for mathematical equations and formulas
- **Liquid Glass UI** - Beautiful macOS-native interface design
- **Complete Privacy** - All processing happens on-device, no data sent to servers
- **App Sandbox Security** - Enhanced system protection and security compliance

## 📋 Installation

1. **Download** the latest DMG file from the releases page
2. **Open** the DMG file
3. **Drag** Vesta.app to your Applications folder
4. **Launch** Vesta from Applications
5. **First Run**: If you see a security warning, right-click Vesta and select "Open"

## 📱 System Requirements

- **macOS 26.0 Beta** or later
- **Apple Silicon Mac** (M1 or later recommended)
- **Xcode 26.0 Beta** for development builds
- **Microphone access** for voice input features

## 🔒 Security & Privacy

### Code Signing
- Signed with **Developer ID Application: Soprano Technologies Inc.**
- **Notarized by Apple** for additional security verification
- **App Sandbox enabled** for enhanced system protection

### Privacy
- **100% On-Device Processing** - All AI computations happen locally
- **No Data Collection** - No analytics, telemetry, or user data sent to servers
- **Microphone Privacy** - Voice input processed locally, never transmitted
- **Transparent Permissions** - Clear explanations for all requested permissions

## 🛠 Build Information

This repository contains the automated build and distribution pipeline for Vesta:

- **Main Script**: `build-vesta-mac-dist.sh` - Complete build automation
- **GitHub Actions**: `.github/workflows/release.yml` - Automated releases
- **Helper Scripts**: `scripts/` - Version management utilities

### Build Process
1. Version number updates (Info.plist, About dialog)
2. Clean build with Xcode Beta
3. Developer ID code signing
4. Apple notarization
5. DMG creation with professional layout
6. GitHub release with DMG attachment (no source tarball)

## 📖 Usage

### For End Users
Simply download the DMG from the releases page and install normally.

### For Developers
```bash
# Build a new version
./build-vesta-mac-dist.sh 0.3.4

# Update version numbers only
./scripts/update-version.sh 0.3.4

# Trigger GitHub Actions build
gh workflow run release.yml -f version=0.3.4
```

## 🔗 Related Repositories

- **Source Code**: Private development repository
- **Build Scripts**: Private build automation repository
- **Distribution**: This repository (public downloads)

## 📊 Release History

See [Releases](https://github.com/scouzi1966/vesta-mac-dist/releases) for complete version history and changelog.

## 💬 Support

For support, feature requests, or bug reports:

1. Check existing [releases](https://github.com/scouzi1966/vesta-mac-dist/releases) for known issues
2. Verify you're running the latest version
3. Ensure your system meets the requirements above

## 📄 License

© 2025 Soprano Technologies Inc. All rights reserved.

## 🏗 Built With

- **Apple Intelligence** - Foundation Models framework
- **SwiftUI** - Native macOS interface
- **Speech Recognition** - Apple Speech framework  
- **LaTeX Rendering** - MathJax integration
- **Automated Pipeline** - GitHub Actions + Custom Scripts

---

🤖 **Built with automated distribution pipeline**  
🔒 **Notarized and code-signed for security**  
🚀 **Ready for production deployment**