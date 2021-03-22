data "template_file" "cluster_autoscaler_chart_values" {
    template = file("${path.module}/cluster-autoscaler-chart-values.tpl")
    vars = {
        cluster_name = var.cluster_name,
        autoscaler_service_account_name = var.autoscaler_service_account_name,
        autoscaler_service_account_iam_role_arn = var.autoscaler_service_account_iam_role_arn
     }
}

resource "local_file" "cluster_autoscaler_chart_values_yaml" {
    filename = var.cluster_autoscaler_chart_values_yaml
    file_permission = "644"
    content = data.template_file.cluster_autoscaler_chart_values.rendered
}
