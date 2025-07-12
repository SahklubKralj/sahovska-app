#!/bin/bash

# Production Build Script for Šahovska Aplikacija
# This script builds the app for production release
#
# Usage: ./scripts/build_production.sh [android|ios|both]
#
# Prerequisites:
# 1. Flutter SDK installed and in PATH
# 2. Android SDK configured (for Android build)
# 3. Xcode installed (for iOS build - macOS only)
# 4. Firebase configuration files in place
# 5. Signing certificates configured

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Šahovska Aplikacija"
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')
BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Production Build Script               ${NC}"
echo -e "${BLUE}  $PROJECT_NAME v$VERSION               ${NC}"
echo -e "${BLUE}  Build Date: $BUILD_DATE                ${NC}"
echo -e "${BLUE}========================================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Flutter
    if ! command_exists flutter; then
        echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
        exit 1
    fi
    
    # Check Flutter doctor
    echo -e "${BLUE}Running Flutter doctor...${NC}"
    flutter doctor
    
    # Check if we're in Flutter project directory
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}Error: Not in Flutter project directory${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
}

# Function to clean and prepare
prepare_build() {
    echo -e "${YELLOW}Preparing build environment...${NC}"
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Run code generation (if any)
    # flutter packages pub run build_runner build --delete-conflicting-outputs
    
    echo -e "${GREEN}Build environment prepared!${NC}"
}

# Function to validate Firebase configuration
check_firebase_config() {
    echo -e "${YELLOW}Checking Firebase configuration...${NC}"
    
    # Check Android config
    if [ "$1" = "android" ] || [ "$1" = "both" ]; then
        if [ ! -f "android/app/google-services.json" ]; then
            echo -e "${RED}Error: android/app/google-services.json not found${NC}"
            echo -e "${YELLOW}Please download it from Firebase Console and place it in android/app/${NC}"
            exit 1
        fi
    fi
    
    # Check iOS config
    if [ "$1" = "ios" ] || [ "$1" = "both" ]; then
        if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
            echo -e "${RED}Error: ios/Runner/GoogleService-Info.plist not found${NC}"
            echo -e "${YELLOW}Please download it from Firebase Console and place it in ios/Runner/${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}Firebase configuration validated!${NC}"
}

# Function to check signing configuration
check_signing() {
    echo -e "${YELLOW}Checking signing configuration...${NC}"
    
    # Check Android signing
    if [ "$1" = "android" ] || [ "$1" = "both" ]; then
        if [ ! -f "android/key.properties" ]; then
            echo -e "${RED}Error: android/key.properties not found${NC}"
            echo -e "${YELLOW}Please create keystore and configure signing. See PRODUCTION_DEPLOYMENT_CHECKLIST.md${NC}"
            exit 1
        fi
        
        # Check if keystore file exists
        KEYSTORE_FILE=$(grep 'storeFile=' android/key.properties | cut -d'=' -f2)
        if [ ! -f "android/$KEYSTORE_FILE" ] && [ ! -f "$KEYSTORE_FILE" ]; then
            echo -e "${RED}Error: Keystore file not found: $KEYSTORE_FILE${NC}"
            echo -e "${YELLOW}Please ensure keystore file exists and path is correct${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}Signing configuration validated!${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    
    # Run unit tests
    flutter test
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
    else
        echo -e "${RED}Tests failed! Please fix issues before building for production.${NC}"
        exit 1
    fi
}

# Function to build Android
build_android() {
    echo -e "${YELLOW}Building Android App Bundle for production...${NC}"
    
    # Build App Bundle (recommended for Play Store)
    flutter build appbundle --release --verbose
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Android build successful!${NC}"
        echo -e "${BLUE}App Bundle location: build/app/outputs/bundle/release/app-release.aab${NC}"
        
        # Get file size
        AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        echo -e "${BLUE}App Bundle size: $AAB_SIZE${NC}"
        
        # Optional: Build APK for testing
        echo -e "${YELLOW}Building APK for testing...${NC}"
        flutter build apk --release --verbose
        
        if [ $? -eq 0 ]; then
            APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
            echo -e "${BLUE}APK location: build/app/outputs/flutter-apk/app-release.apk${NC}"
            echo -e "${BLUE}APK size: $APK_SIZE${NC}"
        fi
    else
        echo -e "${RED}Android build failed!${NC}"
        exit 1
    fi
}

# Function to build iOS
build_ios() {
    echo -e "${YELLOW}Building iOS for production...${NC}"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}Error: iOS build requires macOS${NC}"
        exit 1
    fi
    
    # Check if Xcode is installed
    if ! command_exists xcodebuild; then
        echo -e "${RED}Error: Xcode is not installed${NC}"
        exit 1
    fi
    
    # Build iOS
    flutter build ios --release --no-codesign
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}iOS build successful!${NC}"
        echo -e "${YELLOW}Next steps:${NC}"
        echo -e "${BLUE}1. Open ios/Runner.xcworkspace in Xcode${NC}"
        echo -e "${BLUE}2. Select 'Any iOS Device (arm64)' as target${NC}"
        echo -e "${BLUE}3. Product → Archive${NC}"
        echo -e "${BLUE}4. Distribute App → App Store Connect${NC}"
    else
        echo -e "${RED}iOS build failed!${NC}"
        exit 1
    fi
}

# Function to create build summary
create_build_summary() {
    echo -e "${YELLOW}Creating build summary...${NC}"
    
    SUMMARY_FILE="build_summary_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$SUMMARY_FILE" << EOF
========================================
Production Build Summary
========================================
Project: $PROJECT_NAME
Version: $VERSION
Build Date: $BUILD_DATE
Build Type: $1

Flutter Version:
$(flutter --version)

Build Results:
EOF

    if [ "$1" = "android" ] || [ "$1" = "both" ]; then
        echo "Android App Bundle: build/app/outputs/bundle/release/app-release.aab" >> "$SUMMARY_FILE"
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            echo "Android APK: build/app/outputs/flutter-apk/app-release.apk" >> "$SUMMARY_FILE"
        fi
    fi
    
    if [ "$1" = "ios" ] || [ "$1" = "both" ]; then
        echo "iOS Archive: Ready for Xcode archiving" >> "$SUMMARY_FILE"
    fi
    
    echo "" >> "$SUMMARY_FILE"
    echo "Next Steps:" >> "$SUMMARY_FILE"
    echo "1. Test the build on real devices" >> "$SUMMARY_FILE"
    echo "2. Upload to respective app stores" >> "$SUMMARY_FILE"
    echo "3. Submit for review" >> "$SUMMARY_FILE"
    echo "4. Monitor post-launch analytics" >> "$SUMMARY_FILE"
    
    echo -e "${GREEN}Build summary created: $SUMMARY_FILE${NC}"
}

# Main build function
main() {
    local build_type=${1:-both}
    
    case $build_type in
        android|ios|both)
            ;;
        *)
            echo -e "${RED}Error: Invalid build type '$build_type'${NC}"
            echo -e "${YELLOW}Usage: $0 [android|ios|both]${NC}"
            exit 1
            ;;
    esac
    
    # Run all checks and preparations
    check_prerequisites
    prepare_build
    check_firebase_config "$build_type"
    check_signing "$build_type"
    
    # Ask for confirmation
    echo -e "${YELLOW}Ready to build for production. Continue? (y/N)${NC}"
    read -r confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Build cancelled by user${NC}"
        exit 0
    fi
    
    # Run tests
    run_tests
    
    # Build based on type
    case $build_type in
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        both)
            build_android
            build_ios
            ;;
    esac
    
    # Create summary
    create_build_summary "$build_type"
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Production build completed!          ${NC}"
    echo -e "${GREEN}  Ready for app store deployment       ${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Run main function with all arguments
main "$@"