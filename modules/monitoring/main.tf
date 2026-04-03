# Uptime check for the Cloud Run service
resource "google_monitoring_uptime_check_config" "cloud_run" {
  display_name = "little-helpers-${var.environment}-uptime"
  project      = var.project_id
  timeout      = "10s"
  period       = "300s"

  http_check {
    path         = "/"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = trimprefix(var.cloud_run_url, "https://")
    }
  }
}

# Notification channel (email)
resource "google_monitoring_notification_channel" "email" {
  display_name = "SRE Alerts (${var.environment})"
  project      = var.project_id
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

# Alert policy: uptime check failure
resource "google_monitoring_alert_policy" "uptime_failure" {
  display_name = "little-helpers-${var.environment}-uptime-failure"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Uptime check failing"
    condition_threshold {
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id = \"${google_monitoring_uptime_check_config.cloud_run.uptime_check_id}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      duration        = "300s"

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.project_id"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert policy: Cloud Run high latency (p95 > 2s)
resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "little-helpers-${var.environment}-high-latency"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Cloud Run p95 latency > 2s"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_latencies\""
      comparison      = "COMPARISON_GT"
      threshold_value = 2000
      duration        = "300s"

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_PERCENTILE_95"
        cross_series_reducer = "REDUCE_MAX"
        group_by_fields      = ["resource.label.service_name"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert policy: Cloud Run 5xx error rate
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "little-helpers-${var.environment}-5xx-errors"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Cloud Run 5xx error rate > 5%"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "300s"

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.service_name"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}
