#!/bin/bash

# Destroy All Layers Script
# This script destroys all Terraform layers in REVERSE order

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

# Function to destroy a layer
destroy_layer() {
    local layer_name=$1
    local layer_path=$2
    
    print_warning "Destroying Layer: $layer_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$layer_path"
    
    # Plan destroy
    print_info "Planning destruction..."
    terraform init
    terraform plan -destroy -out=tfplan
    
    # Apply destroy
    print_info "Destroying resources..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    print_success "Layer $layer_name destroyed successfully!"
    echo ""
    
    cd - > /dev/null
}

# Confirmation prompt
confirm_destroy() {
    print_warning "⚠️  WARNING: This will destroy ALL infrastructure!"
    print_warning "This action cannot be undone."
    echo ""
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        print_info "Destruction cancelled."
        exit 0
    fi
    echo ""
}

# Main destruction flow
main() {
    print_warning "🗑️  Starting Terraform Infrastructure Destruction"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Confirm destruction
    confirm_destroy
    
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
    
    # Destroy layers in REVERSE order
    destroy_layer "5-api-gateway" "$TERRAFORM_DIR/5-api-gateway"
    destroy_layer "3-Kubernetes" "$TERRAFORM_DIR/3-kubernetes"
    destroy_layer "2-EKS" "$TERRAFORM_DIR/2-eks"
    destroy_layer "1-Networking" "$TERRAFORM_DIR/1-networking"
    destroy_layer "0-Bootstrap" "$TERRAFORM_DIR/0-bootstrap"
    
    # Display summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "🎉 All layers destroyed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "Infrastructure has been completely removed."
    print_info "All AWS resources have been destroyed."
    echo ""
}

# Run main function
main "$@"