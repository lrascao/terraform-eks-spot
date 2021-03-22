// outputs
output "cluster_id" {
    value = module.eks.cluster_id
    description = "k8s cluster id"
}

output "worker_node_iam_role_arn" {
    value = module.eks.worker_iam_role_arn
    description = "IAM Role ARN of the worker nodes"
}

output "worker_node_iam_role_name" {
    value = module.eks.worker_iam_role_name
    description = "IAM Role name of the worker nodes"
}

output "workers_asg_arns" {
    value = module.eks.workers_asg_arns
    description = "ARNs of the ASGs"
}

output "workers_asg_names" {
    value = module.eks.workers_asg_names
    description = "Names of the ASGs"
}
