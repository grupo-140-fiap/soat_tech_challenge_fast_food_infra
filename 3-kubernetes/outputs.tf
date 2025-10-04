output "metrics_server_status" {
  description = "Status of the metrics-server Helm release"
  value       = helm_release.metrics_server.status
}

output "cluster_autoscaler_status" {
  description = "Status of the cluster-autoscaler Helm release"
  value       = helm_release.cluster_autoscaler.status
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  value       = aws_iam_role.cluster_autoscaler.arn
}