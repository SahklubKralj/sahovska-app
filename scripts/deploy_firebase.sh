#!/bin/bash

# Firebase Deployment Script for Šahovska Aplikacija
# This script deploys Firestore rules, Storage rules, and other Firebase configurations
#
# Usage: ./scripts/deploy_firebase.sh [staging|production]
#
# Prerequisites:
# 1. Firebase CLI installed (npm install -g firebase-tools)
# 2. Authenticated with Firebase (firebase login)
# 3. Firebase project configured (firebase use --add)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-production}
PROJECT_NAME="Šahovska Aplikacija"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Firebase Deployment Script            ${NC}"
echo -e "${BLUE}  $PROJECT_NAME - $ENVIRONMENT          ${NC}"
echo -e "${BLUE}========================================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Firebase CLI
    if ! command_exists firebase; then
        echo -e "${RED}Error: Firebase CLI is not installed${NC}"
        echo -e "${YELLOW}Install with: npm install -g firebase-tools${NC}"
        exit 1
    fi
    
    # Check if authenticated
    if ! firebase projects:list >/dev/null 2>&1; then
        echo -e "${RED}Error: Not authenticated with Firebase${NC}"
        echo -e "${YELLOW}Run: firebase login${NC}"
        exit 1
    fi
    
    # Check if project is configured
    if [ ! -f ".firebaserc" ]; then
        echo -e "${RED}Error: Firebase project not configured${NC}"
        echo -e "${YELLOW}Run: firebase use --add${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
}

# Function to validate rules
validate_rules() {
    echo -e "${YELLOW}Validating Firestore and Storage rules...${NC}"
    
    # Check if rules files exist
    if [ ! -f "firestore.rules" ]; then
        echo -e "${RED}Error: firestore.rules not found${NC}"
        exit 1
    fi
    
    if [ ! -f "storage.rules" ]; then
        echo -e "${RED}Error: storage.rules not found${NC}"
        exit 1
    fi
    
    # Validate Firestore rules
    echo -e "${BLUE}Validating Firestore rules...${NC}"
    firebase firestore:rules:test --project="$ENVIRONMENT" || {
        echo -e "${RED}Firestore rules validation failed${NC}"
        exit 1
    }
    
    echo -e "${GREEN}Rules validation passed!${NC}"
}

# Function to backup current rules
backup_rules() {
    echo -e "${YELLOW}Backing up current rules...${NC}"
    
    local backup_dir="backups/firebase_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Download current rules
    firebase firestore:rules:get "$backup_dir/firestore.rules.backup" --project="$ENVIRONMENT" 2>/dev/null || echo "No existing Firestore rules to backup"
    firebase storage:rules:get "$backup_dir/storage.rules.backup" --project="$ENVIRONMENT" 2>/dev/null || echo "No existing Storage rules to backup"
    
    echo -e "${GREEN}Rules backed up to: $backup_dir${NC}"
}

# Function to deploy Firestore rules
deploy_firestore_rules() {
    echo -e "${YELLOW}Deploying Firestore security rules...${NC}"
    
    firebase deploy --only firestore:rules --project="$ENVIRONMENT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Firestore rules deployed successfully!${NC}"
    else
        echo -e "${RED}Firestore rules deployment failed!${NC}"
        exit 1
    fi
}

# Function to deploy Storage rules
deploy_storage_rules() {
    echo -e "${YELLOW}Deploying Storage security rules...${NC}"
    
    firebase deploy --only storage:rules --project="$ENVIRONMENT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Storage rules deployed successfully!${NC}"
    else
        echo -e "${RED}Storage rules deployment failed!${NC}"
        exit 1
    fi
}

# Function to deploy Firebase Functions (if any)
deploy_functions() {
    if [ -d "functions" ]; then
        echo -e "${YELLOW}Deploying Firebase Functions...${NC}"
        
        # Install dependencies
        cd functions
        npm install
        cd ..
        
        firebase deploy --only functions --project="$ENVIRONMENT"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Functions deployed successfully!${NC}"
        else
            echo -e "${RED}Functions deployment failed!${NC}"
            exit 1
        fi
    else
        echo -e "${BLUE}No Firebase Functions to deploy${NC}"
    fi
}

# Function to set up Firestore indexes
deploy_indexes() {
    if [ -f "firestore.indexes.json" ]; then
        echo -e "${YELLOW}Deploying Firestore indexes...${NC}"
        
        firebase deploy --only firestore:indexes --project="$ENVIRONMENT"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Firestore indexes deployed successfully!${NC}"
        else
            echo -e "${RED}Firestore indexes deployment failed!${NC}"
            exit 1
        fi
    else
        echo -e "${BLUE}No Firestore indexes to deploy${NC}"
    fi
}

# Function to verify deployment
verify_deployment() {
    echo -e "${YELLOW}Verifying deployment...${NC}"
    
    # Get current project info
    firebase projects:list
    
    echo -e "${BLUE}Current Firestore rules:${NC}"
    firebase firestore:rules:list --project="$ENVIRONMENT"
    
    echo -e "${BLUE}Current Storage rules:${NC}"
    firebase storage:rules:list --project="$ENVIRONMENT"
    
    echo -e "${GREEN}Deployment verification completed!${NC}"
}

# Function to create deployment summary
create_deployment_summary() {
    echo -e "${YELLOW}Creating deployment summary...${NC}"
    
    local summary_file="deployment_summary_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$summary_file" << EOF
========================================
Firebase Deployment Summary
========================================
Project: $PROJECT_NAME
Environment: $ENVIRONMENT
Deployment Date: $(date '+%Y-%m-%d %H:%M:%S')

Firebase CLI Version:
$(firebase --version)

Deployed Components:
- Firestore Security Rules: ✓
- Storage Security Rules: ✓
$([ -d "functions" ] && echo "- Cloud Functions: ✓" || echo "- Cloud Functions: N/A")
$([ -f "firestore.indexes.json" ] && echo "- Firestore Indexes: ✓" || echo "- Firestore Indexes: N/A")

Project Information:
$(firebase projects:list --json 2>/dev/null | grep -A 10 "$ENVIRONMENT" || echo "Project info not available")

Next Steps:
1. Test the deployed rules with your app
2. Monitor Firebase console for any issues
3. Check Firebase usage and billing
4. Set up monitoring and alerts

Security Reminders:
- Review rules regularly for security vulnerabilities
- Monitor database usage and access patterns  
- Keep Firebase CLI and project dependencies updated
- Use staging environment for testing rule changes
EOF

    echo -e "${GREEN}Deployment summary created: $summary_file${NC}"
}

# Function to test rules with sample data
test_rules() {
    echo -e "${YELLOW}Testing deployed rules...${NC}"
    
    if [ -f "test/firestore-test.js" ]; then
        echo -e "${BLUE}Running Firestore rules tests...${NC}"
        firebase emulators:exec --only firestore "npm test" --project="$ENVIRONMENT"
    else
        echo -e "${YELLOW}No Firestore rules tests found. Consider creating test/firestore-test.js${NC}"
    fi
    
    echo -e "${GREEN}Rules testing completed!${NC}"
}

# Main deployment function
main() {
    local environment=${1:-production}
    
    case $environment in
        staging|production)
            ;;
        *)
            echo -e "${RED}Error: Invalid environment '$environment'${NC}"
            echo -e "${YELLOW}Usage: $0 [staging|production]${NC}"
            exit 1
            ;;
    esac
    
    # Set Firebase project based on environment
    firebase use "$environment"
    
    echo -e "${YELLOW}Deploying to $environment environment...${NC}"
    
    # Run all checks and deployments
    check_prerequisites
    validate_rules
    
    # Ask for confirmation
    echo -e "${YELLOW}Ready to deploy to $environment. This will update production security rules. Continue? (y/N)${NC}"
    read -r confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled by user${NC}"
        exit 0
    fi
    
    backup_rules
    deploy_firestore_rules
    deploy_storage_rules
    deploy_functions
    deploy_indexes
    verify_deployment
    test_rules
    create_deployment_summary
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Firebase deployment completed!        ${NC}"
    echo -e "${GREEN}  Environment: $environment              ${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "${YELLOW}Important reminders:${NC}"
    echo -e "${BLUE}1. Test your app thoroughly with the new rules${NC}"
    echo -e "${BLUE}2. Monitor Firebase console for any errors${NC}"
    echo -e "${BLUE}3. Check billing and usage after deployment${NC}"
    echo -e "${BLUE}4. Document any rule changes for your team${NC}"
}

# Run main function with all arguments
main "$@"