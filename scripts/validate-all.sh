#!/bin/bash

# Validate All Layers Script
# This script validates all Terraform configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to validate a layer
validate_layer() {
    local layer_name=$1
    local layer_path=$2
    
    print_info "Validating Layer: $layer_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$layer_path"
    
    # Format check
    print_info "Checking format..."
    if terraform fmt -check -recursive; then
        print_success "Format check passed"
    else
        print_warning "Format issues found. Run 'terraform fmt -recursive' to fix."
    fi
    
    # Initialize (required for validation)
    print_info "Initializing..."
    terraform init -backend=false > /dev/null 2>&1
    
    # Validate
    print_info "Validating configuration..."
    if terraform validate; then
        print_success "Validation passed"
    else
        print_error "Validation failed"
        exit 1
    fi
    
    print_success "Layer $layer_name validated successfully!"
    echo ""
    
    cd - > /dev/null
}

# Main validation flow
main() {
    print_info "🔍 Starting Terraform Configuration Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
    
    # Validate all layers
    validate_layer "0-Bootstrap" "$TERRAFORM_DIR/0-bootstrap"
    validate_layer "1-Networking" "$TERRAFORM_DIR/1-networking"
    validate_layer "2-EKS" "$TERRAFORM_DIR/2-eks"
    validate_layer "3-Kubernetes" "$TERRAFORM_DIR/3-kubernetes"
    validate_layer "5-api-gateway" "$TERRAFORM_DIR/5-api-gateway"
    
    # Display summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "🎉 All layers validated successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "All Terraform configurations are valid and properly formatted."
    echo ""
}

# Run main function
main "$@"