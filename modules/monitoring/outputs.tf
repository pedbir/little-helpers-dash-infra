output "uptime_check_id" {
  description = "Uptime check configuration ID"
  value       = google_monitoring_uptime_check_config.cloud_run.uptime_check_id
}

output "notification_channel_name" {
  description = "Monitoring notification channel name"
  value       = google_monitoring_notification_channel.email.name
}
