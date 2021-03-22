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

    // Cluster autoscaler
    autoscaler_service_account_name = local.autoscaler_service_account_name
    autoscaler_service_account_iam_role_name = local.autoscaler_service_account_iam_role_name

    // optional arguments, defaults filled out

    // The AWS region the k8s cluster will run on
    region = "us-west-2"
    // The name of your k8s cluster
    cluster_name = "eks-spot"

    // A list of instance types on which the worker nodes will run on, the first
    // in this list is chosen as the on-demand instance type
    instance_types = ["t2.small"]

    // Minimum number of on demand k8s workers nodes
    // We need at least one on-demand node that should be running the cluster
    // autoscaler pod, this is to ensure that it's working because hes the one
    // who will provision new nodes
    min_on_demand_size = 1
    // Maximum number of on demand k8s workers nodes
    max_on_demand_size = 5
    // Minimum number of spot instances k8s workers nodes
    min_spot_size = 0
    // Maximum number of spot instances k8s workers nodes
    max_spot_size = 5

    // Userdata to pre-append to the default userdata.
    userdata_prefix = <<EOF
          echo Installing tools
          sudo yum install awscli -y
          EOF
    userdata_suffix = ""

    tags = {
        "a_tag" = "a_value"
    }
}
```

## Add cluster autoscaler funcionality

This will scale up new nodes when a pod is detected as being unschedulable.

### Ensure that a IAM OIDC is created [instructions](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)

```
$ aws-vault exec <aws-profile> -- aws eks describe-cluster --name <cluster-name> --query "cluster.identity.oidc.issuer" --output text
https://oidc.eks.<aws-region>.amazonaws.com/id/E2C04BBC0C9416141F9BAF4F042497B2
<copy the E2C04BBC0C9416141F9BAF4F042497B2 bit>

$ aws-vault exec <aws-profile> -- aws iam list-open-id-connect-providers | grep E2C04BBC0C9416141F9BAF4F042497B2
"Arn": "arn:aws:iam::111122223333:oidc-provider/oidc.eks.<aws-region>.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
```

If you don't get the arn expected output then you'll need to create the OIDC provider:

```
$ aws-vault exec <aws-profile> -- eksctl utils associate-iam-oidc-provider --cluster <cluster-name> --approve
```

### Install the cluster autoscaler chart [instructions](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v14.0.0/examples/irsa)

```
$ helm repo add autoscaler https://kubernetes.github.io/autoscaler
$ helm repo update
$ helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler-chart --values=cluster-autoscaler-chart-values.yaml
```

## Add monitoring funcionality

### Install metrics-server

```
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

