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
