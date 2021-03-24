variable "region" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "node_termination_handler_service_account_name" {
    type = string
}

variable "node_termination_handler_service_account_iam_role_arn" {
    type = string
}

variable "node_termination_handler_queue_url" {
    type = string
}

variable "node_termination_handler_chart_values_yaml" {
    type = string
    default = "node-termination-handler-chart-values.yaml"
}
