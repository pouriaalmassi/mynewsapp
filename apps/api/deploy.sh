#!/bin/bash

set -e

# Configuration
SERVICE_NAME="mynewsapi"
REGION="us-central1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}    News API - Cloud Run Deployment Script     ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No Google Cloud project set${NC}"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo -e "${GREEN}Project: ${PROJECT_ID}${NC}"
echo -e "${GREEN}Service: ${SERVICE_NAME}${NC}"
echo -e "${GREEN}Region: ${REGION}${NC}"

# Function to check if a secret exists
secret_exists() {
    gcloud secrets describe "$1" &>/dev/null
}

# Function to create a secret
create_secret() {
    local secret_name=$1
    local prompt_message=$2
    
    if secret_exists "$secret_name"; then
        echo -e "${YELLOW}Secret '$secret_name' already exists${NC}"
    else
        echo -e "${YELLOW}Creating secret: $secret_name${NC}"
        read -sp "$prompt_message: " secret_value
        echo
        echo -n "$secret_value" | gcloud secrets create "$secret_name" --data-file=-
        echo -e "${GREEN}Secret '$secret_name' created${NC}"
    fi
}

# Enable required APIs
echo -e "\n${BLUE}Enabling required APIs...${NC}"
gcloud services enable \
    run.googleapis.com \
    secretmanager.googleapis.com \
    cloudbuild.googleapis.com \
    --quiet

# Setup secrets
echo -e "\n${BLUE}Setting up secrets...${NC}"
create_secret "API_KEY" "Enter your API key for this service"
create_secret "NEWS_API_KEY" "Enter your News API key (from newsapi.org)"

# Grant Secret Manager access to Cloud Run service account
echo -e "\n${BLUE}Configuring IAM permissions...${NC}"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

for secret in API_KEY NEWS_API_KEY; do
    gcloud secrets add-iam-policy-binding "$secret" \
        --member="serviceAccount:${SERVICE_ACCOUNT}" \
        --role="roles/secretmanager.secretAccessor" \
        --quiet 2>/dev/null || true
done
echo -e "${GREEN}IAM permissions configured${NC}"

# Deploy to Cloud Run
#
# gcloud run deploy is used to create or update a Cloud Run service. And it 
# is sort of a combo command. If you have source code instead of a built image, 
# it'll invoke Cloud Build to build your image, then it'll invoke services 
# update, and then it'll optionally add-iam-policy-binding to allow unauthenticated users.
# 
# If all you need is to update a Cloud Run service with an already built image, 
# then you can use gcloud run services update, which will update Cloud Run 
# environment variables and other configuration settings.
# 
echo -e "\n${BLUE}Deploying to Cloud Run...${NC}"
gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --region "$REGION" \
    --allow-unauthenticated \
    --set-secrets "API_KEY=API_KEY:latest,NEWS_API_KEY=NEWS_API_KEY:latest" \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10 \
    --quiet

# Get the service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format="value(status.url)")

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}    Deployment Complete!                        ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo -e "\n${BLUE}Service URL:${NC} $SERVICE_URL"
echo -e "\n${YELLOW}Test the deployment:${NC}"
echo -e "  curl ${SERVICE_URL}/api/news/health"
echo -e "\n${YELLOW}Test with authentication:${NC}"
echo -e "  curl -H \"Authorization: Bearer YOUR_API_KEY\" ${SERVICE_URL}/api/news/top-headlines"
