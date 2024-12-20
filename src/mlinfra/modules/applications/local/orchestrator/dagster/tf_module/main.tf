locals {
  dagster_helmchart_set = [{
    name  = "ingress.dagsterWebserver.host"
    value = var.dagster_endpoint
    type  = "auto"
    }
  ]
}

module "dagster_helmchart" {
  source           = "../../../../../local/helm_chart"
  name             = "dagster"
  namespace        = "dagster"
  create_namespace = true
  repository       = "https://dagster-io.github.io/helm"
  chart            = "dagster"
  chart_version    = var.dagster_chart_version
  values = templatefile("${path.module}/values.yaml", {
    resources = jsonencode(var.resources)
  })
  set = local.dagster_helmchart_set
}
