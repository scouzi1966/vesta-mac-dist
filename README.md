# Vesta — macOS Distribution

Pre-built, signed, and notarized DMG releases for [Vesta](https://github.com/scouzi1966/vesta-mac).

## Install

### Homebrew (recommended)

```bash
brew tap scouzi1966/afm
brew install --cask scouzi1966/afm/vesta-mac
```

### Direct Download

| Channel | Version | Download | Date |
|---------|---------|----------|------|
| **Stable** | 0.9.6 | [Vesta-0.9.6.dmg](https://github.com/scouzi1966/vesta-mac-dist/releases/download/v0.9.6/Vesta-0.9.6.dmg) | 2026-03-04 |
| Nightly | Vesta-next | [Vesta-next.dmg](https://github.com/scouzi1966/vesta-mac-dist/releases/download/Vesta-next/Vesta-next.dmg) | Vesta-next |

### Nightly via Homebrew

```bash
brew install --cask scouzi1966/afm/vesta-mac-next
```

## Verify

```bash
# Check SHA256
shasum -a 256 ~/Downloads/Vesta-*.dmg

# Check code signature
codesign --verify --deep --strict /Applications/Vesta.app

# Check notarization
spctl --assess --type execute /Applications/Vesta.app
```
