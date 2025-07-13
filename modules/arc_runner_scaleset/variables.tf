variable "namespace" {
  type = string
}

variable "namespace_depends_on" {
  type = any
}

variable "github_config_url" {
  type = string
}

variable "github_config_secret_name" {
  type = string
}

variable "release_name" {
  type        = string
  description = "Helm release name for the runner scale set"
  default     = "arc-runner-set"
}

variable "runner_group" {
  type        = string
  description = "GitHub runner group"
  default     = "Default"
}

variable "min_runners" {
  type        = number
  description = "Minimum number of runners"
  default     = 0
}

variable "max_runners" {
  type        = number
  description = "Maximum number of runners"
  default     = 10
}

variable "runner_image" {
  type        = string
  description = "Container image for the runners"
  default     = "ghcr.io/actions/actions-runner:latest"
}

variable "chart_version" {
  type        = string
  description = "Version of the ARC runner scale set chart"
  default     = "0.12.1"
}