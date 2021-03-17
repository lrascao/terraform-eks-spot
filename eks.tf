data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.selected.id
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "13.2.1"

    cluster_name    = var.cluster_name
    cluster_version = "1.19"

    vpc_id          = data.aws_vpc.selected.id
    subnets         = data.aws_subnet_ids.public.ids

    tags = var.tags

    worker_groups_launch_template = [
    {
      name                    = "spot-ng-1"
      instance_type           = var.instance_types[0]
      override_instance_types = var.instance_types
      spot_instance_pools     = length(var.instance_types)
      asg_min_size            = var.min_size 
      asg_max_size            = var.max_size 
      asg_desired_capacity    = 1
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = true
      autoscalling_enabled    = true
      pre_userdata            = var.userdata_prefix
      additional_userdata     = var.userdata_suffix
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }]

    // this allows the power user root access over the k8s cluster
    map_roles = [
    {
        rolearn = var.power_user_role_arn 
        username = "power_user"
        groups = ["system:masters"]
    }]

    // the following will generate a kubeconfig_<cluster_name> file to the current directory
    // you can easily merge the two using github.com/alexlafroscia/yaml-merge
    //      yaml-merge kubeconfig ~/.kube/config > ~/.kube/config
    //
    // this also assumes that you are using aws-vault and have it properly configured
    //
    write_kubeconfig = true
    config_output_path = "kubeconfig" 
    kubeconfig_aws_authenticator_command = "aws-vault"
    kubeconfig_aws_authenticator_command_args = ["exec", var.power_user_aws_sso_profile, "--", "aws", "eks", "get-token", "--cluster-name", var.cluster_name]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

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
