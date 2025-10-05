# Metrics Server Helm Release
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.metrics_server_version
  timeout    = 600

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [data.terraform_remote_state.eks]
}
