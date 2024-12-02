provider "google" {
  project = var.project_id
  region  = var.region
}

# Create Pub/Sub topic for logs
resource "google_pubsub_topic" "security_logs_topic" {
  name = "security-logs-topic"
}

# Create Pub/Sub subscription
resource "google_pubsub_subscription" "security_logs_subscription" {
  name  = "security-logs-subscription"
  topic = google_pubsub_topic.security_logs_topic.id
}

# Logging sink to capture security events
resource "google_logging_project_sink" "security_logs_sink" {
  name        = "security-logs-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.security_logs_topic.id}"
  filter      = "logName:cloudaudit.googleapis.com/activity AND severity>=ERROR"
}

# IAM binding for logging sink service account
resource "google_pubsub_topic_iam_binding" "pubsub_publisher" {
  topic = google_pubsub_topic.security_logs_topic.id
  role  = "roles/pubsub.publisher"

  members = [
   # "serviceAccount:${google_logging_project_sink.security_logs_sink.writer_identity}" #update proper compute service acc below
    "serviceAccount:xxxxxxxxxxx-compute@developer.gserviceaccount.com"
  ]
}

# Logs-based metric for IAM changes - this needs to be from active resource-audited metric
resource "google_logging_metric" "iam_change_metric" {
  name        = "iam-change-metric"
  description = "Logs-based metric for IAM changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}


# Notification channel for email alerts
resource "google_monitoring_notification_channel" "email_alert" {
  display_name = "Security Alerts Email"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# Alerting policy for IAM changes
resource "google_monitoring_alert_policy" "iam_change_alert" {
  display_name          = "IAM Change Alert"
  notification_channels = [google_monitoring_notification_channel.email_alert.id]
  combiner              = "AND"

  conditions {
    display_name = "IAM Change Condition"
    condition_threshold {
      comparison     = "COMPARISON_GT"
      duration       = "60s"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
      filter = "resource.type=\"global\" AND metric.type=\"logging.googleapis.com/user/iam-change-metric\""
    }
  }
}

