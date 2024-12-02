#!/bin/bash

# Load variables from terraform.tfvars file
TFVARS_FILE="terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
  echo "Error: terraform.tfvars file not found in the current directory."
  exit 1
fi

# Extract values from the terraform.tfvars file
PROJECT_ID=$(grep -oP '^project_id\s*=\s*"\K[^"]+' "$TFVARS_FILE")
REGION=$(grep -oP '^region\s*=\s*"\K[^"]+' "$TFVARS_FILE")
ALERT_EMAIL=$(grep -oP '^alert_email\s*=\s*"\K[^"]+' "$TFVARS_FILE")

# Validate extracted variables
if [ -z "$PROJECT_ID" ] || [ -z "$REGION" ] || [ -z "$ALERT_EMAIL" ]; then
  echo "Error: One or more required variables (project_id, region, alert_email) are missing in terraform.tfvars."
  exit 1
fi

# Test script starts here
echo "Using the following configuration:"
echo "PROJECT_ID: $PROJECT_ID"
echo "REGION: $REGION"
echo "ALERT_EMAIL: $ALERT_EMAIL"

# Example: Publish a message to the Pub/Sub topic
echo "Publishing test message to Pub/Sub topic"
gcloud pubsub topics publish security-logs-topic --message="Test event for Pub/Sub topic"

# Simulate an IAM policy change
echo "Simulating IAM policy change"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:service-xxxxxxxxxxxx@compute-system.iam.gserviceaccount.com" \ #update proper service account here
  --role="roles/viewer"

# Simulate writing an error log entry to Cloud Logging
echo "Writing an error log to Cloud Logging"
gcloud logging write test-log "This is a test error log" --severity=ERROR

# Check for logs-based metric data
echo "Checking IAM change metric"
gcloud logging metrics describe iam-change-metric

# Test the alert notification (if needed)
echo "Testing alert notification"
gcloud monitoring policies conditions test \
  --condition-name="IAM Change Condition" \
  --policy-name="IAM Change Alert" \
  --project=$PROJECT_ID

echo "Test completed."

