data "template_file" "node_termination_handler_chart_values" {
    template = file("${path.module}/node-termination-handler-chart-values.tpl")
    vars = {
        region = var.region
        cluster_name = var.cluster_name,
        node_termination_handler_service_account_name = var.node_termination_handler_service_account_name,
        node_termination_handler_service_account_iam_role_arn = var.node_termination_handler_service_account_iam_role_arn
        node_termination_handler_queue_url = var.node_termination_handler_queue_url
     }
}

resource "local_file" "node_termination_handler_chart_values_yaml" {
    filename = var.node_termination_handler_chart_values_yaml
    file_permission = "644"
    content = data.template_file.node_termination_handler_chart_values.rendered
}
