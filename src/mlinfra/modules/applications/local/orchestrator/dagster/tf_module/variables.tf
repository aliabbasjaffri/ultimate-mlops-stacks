variable "dagster_chart_version" {
  type        = string
  description = "Version of the Dagster Helm chart to use"
  default     = "1.8.13"
}

variable "resources" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  description = "Resource requests and limits for Dagster pods"
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

variable "dagster_endpoint" {
  type    = string
  default = "dagster.localhost"
}
