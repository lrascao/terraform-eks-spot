variable "region" {
    type = string
    default = "us-west-2"
    description = "The AWS region the k8s cluster will run on"
}

variable "vpc_id" {
    type = string
    description = "VPC"
}

variable "cluster_name" {
    type = string
    default = "eks-spot"
    description = "The name of your k8s cluster"
}

variable "instance_types" {
    type = list(string)
    default = ["t2.small"]
    description = "A list of instance types on which the worker nodes will run on"
}

variable "min_size" {
    type = number
    default = 1
    description = "Minimum number of k8s workers nodes"
}

variable "max_size" {
    type = number
    default = 1
    description = "Maximum number of k8s workers nodes"
}

variable "power_user_aws_sso_profile" {
    type = string
    description = "The name of your AWS SSO profile in ~/.aws/config that has the PowerUser role associated"
}

variable "power_user_role_arn" {
    type = string
    description = "The ARN of your Power User IAM role (without the 'aws-reserved/sso.amazonaws.com/' bit)" 
}

variable "autoscaler_service_account_namespace" {
    type = string
    description = "Namespace where to create the autoscaler service account" 
    default = "kube-system"
}

variable "autoscaler_service_account_name" {
    type = string
    description = "Name of the autoscaler service account" 
    default = "cluster-autoscaler-aws-cluster-autoscaler-chart"
}

variable "autoscaler_service_account_iam_role_name" {
    type = string
    description = "Name of the autoscaler service account IAM role name" 
}

variable "userdata_prefix" {
    type = string
    description = "Userdata to prepend to the default userdata"
}

variable "userdata_suffix" {
    type = string
    description = "Userdata to append to the default userdata"
}

variable "tags" {
    type = map(string)
    description = "Tags to be applied"
}

variable "on_demand_base_capacity" {
    type = number
    default = 1
    description = "On many instances to run on-demand"
}

variable "on_demand_percentage_above_base_capacity" {
    type = number
    default = 25 
    description = "If set to 25 for example, spot instances will be 1 in 4 new nodes, when auto-scaling"
}

