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

variable "min_on_demand_size" {
    type = number
    default = 1
    description = "Minimum number of on demand k8s workers nodes"
}

variable "max_on_demand_size" {
    type = number
    default = 1
    description = "Maximum number of on demand k8s workers nodes"
}

variable "on_demand_percentage_above_base_capacity" {
    type = number
    default = 10 
    description = "Percentage of on-demand instances above base capacity"
}

variable "min_spot_size" {
    type = number
    default = 1
    description = "Minimum number of spot instance k8s workers nodes"
}

variable "max_spot_size" {
    type = number
    default = 1
    description = "Maximum number of spot instance k8s workers nodes"
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
    default = "aws-cluster-autoscaler-sa"
}

variable "autoscaler_service_account_iam_role_name" {
    type = string
    description = "Name of the autoscaler service account IAM role name" 
}

variable "node_termination_handler_service_account_namespace" {
    type = string
    description = "Namespace where to create the node termination handler service account" 
    default = "kube-system"
}

variable "node_termination_handler_service_account_name" {
    type = string
    description = "Name of the node termination handler service account" 
    default = "aws-node-termination-handler-sa"
}

variable "node_termination_handler_service_account_iam_role_name" {
    type = string
    description = "Name of the node termination handler service account IAM role name" 
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

