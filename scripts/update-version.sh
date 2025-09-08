#!/bin/bash

# Vesta Version Update Helper Script
# Updates version numbers in source files without building
# Usage: ./scripts/update-version.sh <version>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.3.4"
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(dirname "$SCRIPT_DIR")"
VESTA_REPO_DIR="$(dirname "$DIST_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Updating Vesta version to $VERSION${NC}"

# Validate version format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Invalid version format. Use x.y.z (e.g., 0.3.4)${NC}"
    exit 1
fi

# Update Info.plist
INFO_PLIST="$VESTA_REPO_DIR/Vesta/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    current_build=$(plutil -extract CFBundleVersion raw "$INFO_PLIST")
    new_build=$((current_build + 1))
    
    plutil -replace CFBundleShortVersionString -string "$VERSION" "$INFO_PLIST"
    plutil -replace CFBundleVersion -string "$new_build" "$INFO_PLIST"
    
    echo -e "${GREEN}✓ Updated Info.plist to version $VERSION (build $new_build)${NC}"
else
    echo -e "${RED}❌ Info.plist not found at $INFO_PLIST${NC}"
    exit 1
fi

# Update VestaApp.swift
VESTA_APP="$VESTA_REPO_DIR/Vesta/VestaApp.swift"
if [ -f "$VESTA_APP" ]; then
    sed -i '' "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version $VERSION/g" "$VESTA_APP"
    echo -e "${GREEN}✓ Updated VestaApp.swift About dialog${NC}"
else
    echo -e "${RED}❌ VestaApp.swift not found at $VESTA_APP${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Version update complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Review changes: git diff"
echo -e "  2. Build release: ./build-vesta-mac-dist.sh $VERSION"