# Terraform EKS spot

<!-- [![Help Contribute to Open Source](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc/badges/users.svg)](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc) -->
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/lrascao/terraform-eks-spot)

Terraform module to create an EKS cluster running on EC2 spot instances.

## Assumes that you're using:

* An already existing VPC
* [`aws-vault`](https://github.com/99designs/aws-vault)
* AWS SSO Federated Login
* Two AWS Profiles in your `~/.aws/config`
    * Admin (can create IAM roles)
    * Power User
* [`yaml-merge`](github.com/alexlafroscia/yaml-merge)

## Usage


```hcl
module "eks" {
    // required arguments, no defaults

    // VPC
    vpc_id = "vpc-xyz"
    // The name of your AWS SSO profile in ~/.aws/config that has the PowerUser role associated
    power_user_aws_sso_profile = "power-user-aws-profile"
    // The ARN of your Power User IAM role (without the 'aws-reserved/sso.amazonaws.com/' bit)
    power_user_role_arn = "arn:aws:iam::<account id>:role/<role name>"

    // optional arguments, defaults filled out

    // The AWS region the k8s cluster will run on
    region = "us-west-2"
    // The name of your k8s cluster
    cluster_name = "eks-spot"
    // A list of instance types on which the worker nodes will run on
    instance_types = ["t2.small"]
    // Minimum number of k8s workers nodes
    min_size = 1
    // Maximum number of k8s workers nodes
    max_size = 1
}
```

