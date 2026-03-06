#!/bin/bash

# Deeplink Testing Script for LeapMobileSDKDemo
# Usage: ./test_deeplink.sh [deeplink_type]
# Example: ./test_deeplink.sh schedule

BUNDLE_ID="tech.leapevent.LeapMobileSDKDemo"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo -e "${BLUE}=== LeapMobileSDKDemo Deeplink Tester ===${NC}\n"
    echo "Usage: $0 [deeplink_type]"
    echo ""
    echo "Available deeplink types:"
    echo "  schedule   - Test schedule deeplink (fanaticssdkstaging://schedule)"
    echo "  talents    - Test talents deeplink (fanaticssdkstaging://talents)"
    echo "  brands     - Test brands deeplink (fanaticssdkstaging://brands)"
    echo "  badges     - Test badges deeplink (fanaticssdkstaging://huziBadges)"
    echo "  register   - Test registration deeplink (fanaticssdkstaging://thuziRegistration)"
    echo "  sample     - Test sample app deeplink (sampleapp://test)"
    echo "  custom     - Enter a custom URL"
    echo ""
    echo "Or run without arguments to see this menu."
    echo ""
    echo -e "${YELLOW}Note: Make sure the app is running in the iOS Simulator${NC}"
}

# Function to get the booted simulator ID
get_booted_simulator() {
    xcrun simctl list devices booted | grep "Booted" | head -1 | grep -E -o "[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}"
}

# Function to check if app is installed
check_app_installed() {
    local sim_id=$1
    xcrun simctl get_app_container "$sim_id" "$BUNDLE_ID" &> /dev/null
    return $?
}

# Function to open deeplink
open_deeplink() {
    local url=$1
    local sim_id=$2
    
    echo -e "${GREEN}✓ Opening deeplink: ${BLUE}$url${NC}"
    xcrun simctl openurl "$sim_id" "$url"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Deeplink sent successfully!${NC}"
    else
        echo -e "${RED}✗ Failed to send deeplink${NC}"
        exit 1
    fi
}

# Main script
main() {
    # Check if simulator is running
    SIM_ID=$(get_booted_simulator)
    
    if [ -z "$SIM_ID" ]; then
        echo -e "${RED}✗ No booted simulator found${NC}"
        echo -e "${YELLOW}Please start the iOS Simulator and run the app first${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Found booted simulator: $SIM_ID${NC}"
    
    # Check if app is installed
    if ! check_app_installed "$SIM_ID"; then
        echo -e "${RED}✗ App not installed on simulator${NC}"
        echo -e "${YELLOW}Please build and run the app first${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ App is installed${NC}\n"
    
    # Handle deeplink type
    DEEPLINK_TYPE=$1
    
    case "$DEEPLINK_TYPE" in
        "schedule")
            open_deeplink "fanaticssdkstaging://schedule" "$SIM_ID"
            ;;
        "talents")
            open_deeplink "fanaticssdkstaging://talents" "$SIM_ID"
            ;;
        "brands")
            open_deeplink "fanaticssdkstaging://brands" "$SIM_ID"
            ;;
        "badges")
            open_deeplink "fanaticssdkstaging://huziBadges" "$SIM_ID"
            ;;
        "register")
            open_deeplink "fanaticssdkstaging://thuziRegistration" "$SIM_ID"
            ;;
        "sample")
            open_deeplink "sampleapp://test" "$SIM_ID"
            ;;
        "custom")
            echo -n "Enter custom deeplink URL: "
            read CUSTOM_URL
            if [ -z "$CUSTOM_URL" ]; then
                echo -e "${RED}✗ No URL provided${NC}"
                exit 1
            fi
            open_deeplink "$CUSTOM_URL" "$SIM_ID"
            ;;
        *)
            show_usage
            exit 0
            ;;
    esac
}

# Run main function
main "$@"
