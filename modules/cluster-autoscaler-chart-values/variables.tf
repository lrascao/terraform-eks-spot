variable "cluster_name" {
    type = string
}

variable "autoscaler_service_account_name" {
    type = string
}

variable "autoscaler_service_account_iam_role_arn" {
    type = string
}

variable "cluster_autoscaler_chart_values_yaml" {
    type = string
    default = "cluster-autoscaler-chart-values.yaml"
}
