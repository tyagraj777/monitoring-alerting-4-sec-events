# monitoring-alerting-4-sec-events
Create a monitoring and alerting system for security events, such as unauthorized access or policy violations.

To simulate the IAM policy change event use provided shell script "test-terraform-setup2" it will pull all variables from "terraform.tfvars"

you need to update both file prior to running terraform validate, plan, apply

Script Overview

Terraform Initialization and Application:

1. terraform init initializes the Terraform environment, ensuring the required modules and providers are ready.
   
terraform apply -auto-approve applies the Terraform configuration to provision the infrastructure without user prompts.

3. Retrieve Terraform Outputs:

Variables like PROJECT_ID, REGION, and ALERT_EMAIL are fetched using terraform output. These are used to interact with the GCP services.

3. Test Steps:

* Publish a Test Message: Publishes a test message to a Pub/Sub topic to ensure it's set up correctly.

* Simulate IAM Policy Change: Adds an IAM role binding to simulate a change that triggers logging and alerts.

* Log Entry Simulation: Writes an error log entry to verify if logging and metrics capture the event.

* Check Logs-Based Metric: Uses gcloud logging metrics describe to verify the custom metric based on logs.

* Test Alert Notifications: Simulates testing of alerting policies with the specified IAM change condition.

* Completion Message: Outputs "Test completed" when all steps are executed.
  

Outputs Test completed. when all steps are executed.
