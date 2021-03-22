module "cluster_autoscaler_chart_values_yaml" {
    source = "./modules/cluster-autoscaler-chart-values"

    cluster_name = var.cluster_name
    autoscaler_service_account_name = var.autoscaler_service_account_name
    autoscaler_service_account_iam_role_arn = module.iam_assumable_role_admin.this_iam_role_arn
}
