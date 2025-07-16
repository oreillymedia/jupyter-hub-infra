#!/bin/bash

# Configuration
# GET from Terraform output or 1password
JUPYTERHUB_URL=""
API_TOKEN=""
USERNAME=""
PROFILE="gpu-l4" #or choose the cpu-c3 profile
IMAGE="jupyter/datascience-notebook:latest" # Random test image

# Create user (if needed)
user_response=$(curl -s -X POST \
     -H "Authorization: token $API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"usernames\": [\"$USERNAME\"]}" \
     $JUPYTERHUB_URL/hub/api/users)
echo "Response: $user_response"

echo "Creating user $USERNAME server..."
curl -s -X POST \
    -H "Authorization: token $API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"profile\": \"$PROFILE\",
        \"image\": \"$IMAGE\"
    }" \
    $JUPYTERHUB_URL/hub/api/users/$USERNAME/server

# Wait for server to be ready
# NOTE: this takes a bit of time with Autopilot clusters. 
# We also have the option to configure node pools with the
# gke-standard-public-cluster module.

if [[ "$server_response" != *"already running"* ]]; then
    echo "Waiting for server to be ready..."
    max_attempts=50
    attempt=1

    while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt/$max_attempts:"
    # Get user info
    user_info=$(curl -s -H "Authorization: token $API_TOKEN" $JUPYTERHUB_URL/hub/api/users/$USERNAME)
    ready_field=$(echo "$user_info" | jq -r '.servers."".ready // false')
    pending_field=$(echo "$user_info" | jq -r '.servers."".pending // "unknown"')
    
    echo "  Ready: $ready_field"
    echo "  Pending: $pending_field"
    
    # Check if server is ready
    if [ "$ready_field" = "true" ]; then
        echo "Server is ready!"
        break
    elif [ "$pending_field" = "failed" ]; then
        echo "Server failed to start. Check Kubernetes logs for details."
        exit 1
    fi
    
    attempt=$((attempt+1))
    echo "  Waiting 10 more seconds..."
    sleep 10
    done
fi

# Generate a user token for direct access
echo "Generating access token..."
token_response=$(curl -s -X POST \
     -H "Authorization: token $API_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"expires_in": 3600}' \
     $JUPYTERHUB_URL/hub/api/users/$USERNAME/tokens)

user_token=$(echo "$token_response" | jq -r '.token // empty')

if [ -z "$user_token" ]; then
  # Try to extract error message
  error_msg=$(echo "$token_response" | jq -r '.message // "Unknown error"')
  echo "Failed to generate token. Error: $error_msg"
  exit 1
fi

# Output the direct access URL
direct_url="$JUPYTERHUB_URL/user/$USERNAME/lab?token=$user_token"
echo "Direct access URL: $direct_url"