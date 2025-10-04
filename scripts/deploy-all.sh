#!/bin/bash

# Deploy All Layers Script
# This script deploys all Terraform layers in the correct order

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

# Function to deploy a layer
deploy_layer() {
    local layer_name=$1
    local layer_path=$2
    
    print_info "Deploying Layer: $layer_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$layer_path"
    
    # Initialize Terraform
    print_info "Initializing Terraform..."
    terraform init
    
    # Plan
    print_info "Planning changes..."
    terraform plan -out=tfplan
    
    # Apply
    print_info "Applying changes..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    print_success "Layer $layer_name deployed successfully!"
    echo ""
    
    cd - > /dev/null
}

# Main deployment flow
main() {
    print_info "🚀 Starting Terraform Infrastructure Deployment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
    
    # Deploy layers in order
    deploy_layer "0-Bootstrap" "$TERRAFORM_DIR/0-bootstrap"
    deploy_layer "1-Networking" "$TERRAFORM_DIR/1-networking"
    deploy_layer "2-EKS" "$TERRAFORM_DIR/2-eks"
    
    # Configure kubectl
    print_info "Configuring kubectl..."
    aws eks update-kubeconfig \
        --name eks-soat-fast-food-dev \
        --region us-east-1 \
        --profile default
    print_success "kubectl configured successfully!"
    echo ""
    
    # Verify cluster
    print_info "Verifying cluster..."
    kubectl get nodes
    echo ""
    
    deploy_layer "3-Kubernetes" "$TERRAFORM_DIR/3-kubernetes"
    deploy_layer "4-API-Gateway" "$TERRAFORM_DIR/4-api-gateway"
    
    # Display summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "🎉 All layers deployed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Display important outputs
    print_info "📊 Important Information:"
    echo ""
    
    print_info "API Gateway URL:"
    cd "$TERRAFORM_DIR/4-api-gateway"
    terraform output stage_invoke_url
    cd - > /dev/null
    echo ""
    
    print_info "Cluster Information:"
    kubectl cluster-info
    echo ""
    
    print_info "Nodes:"
    kubectl get nodes
    echo ""
    
    print_warning "Next Steps:"
    echo "  1. Deploy your applications to Kubernetes"
    echo "  2. Configure API Gateway routes and integrations"
    echo "  3. Set up monitoring and alerting"
    echo "  4. Configure CI/CD pipelines"
    echo ""
}

# Run main function
main "$@"