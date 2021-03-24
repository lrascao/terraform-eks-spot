//
// SQS Queue and policy
//
resource "aws_sqs_queue" "lifecycle_hook_scale_in_notification_sqs" {
    
    name_prefix = format("eks-%s-scalein-notifications", var.cluster_name)
    message_retention_seconds = 300
    receive_wait_time_seconds = 10

    tags = var.tags
}

resource "aws_sqs_queue_policy" "lifecycle_hook_scale_in_notification_sqs_policy" {
    queue_url = aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.id
    policy = data.aws_iam_policy_document.lifecycle_hook_scale_in_notification_sqs_policy.json
}

data "aws_iam_policy_document" "lifecycle_hook_scale_in_notification_sqs_policy" {
    statement {
        sid    = "ScaleInNotificationSQSPolicy"
        effect = "Allow"

        actions = [
          "sqs:SendMessage"
        ]

        resources = [aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.arn]

        principals {
              type        = "Service"
              identifiers = ["events.amazonaws.com",
                             "sqs.amazonaws.com"]
        }

    }
}

//
// ASG Lifecycle hooks
//
resource "aws_autoscaling_lifecycle_hook" "aws_asg_lifecycle_hooks" {
    for_each = toset(module.eks.workers_asg_names)
    name = format("%s-scalein-hook", each.key)
    autoscaling_group_name = each.key
    default_result         = "CONTINUE"
    heartbeat_timeout      = 300
    lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

//
// EC2 Instance termination rule and target
//
resource "aws_cloudwatch_event_rule" "ec2_instance_termination" {
  name = format("eks-%s-ec2-instance-termination", var.cluster_name)
  description = "Capture EC2 instance terminate event"

  event_pattern = <<EOF
{
    "source": [ "aws.autoscaling"],
    "detail-type": [
        "EC2 Instance-terminate Lifecycle Action"
    ]
}
EOF
}

resource "aws_cloudwatch_event_target" "ec2_instance_termination" {
    target_id = format("eks-%s-ec2-instance-termination-event-target", var.cluster_name)
    rule = aws_cloudwatch_event_rule.ec2_instance_termination.name
    arn = aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.arn
}

//
// EC2 Spot Instance interruption rule and target
//
resource "aws_cloudwatch_event_rule" "ec2_spot_instance_interruption" {
  name = format("eks-%s-ec2-spot-instance-interruption", var.cluster_name)
  description = "Capture EC2 Spot instance interruption events"

  event_pattern = <<EOF
{
    "source": ["aws.ec2"],
    "detail-type": [
        "EC2 Spot Instance Interruption Warning"
    ]
}
EOF
}

resource "aws_cloudwatch_event_target" "ec2_spot_instance_interruption" {
    target_id = format("eks-%s-ec2-spot-instance-interruption-event-target", var.cluster_name)
    rule = aws_cloudwatch_event_rule.ec2_spot_instance_interruption.name
    arn = aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.arn
}

//
// EC2 Instance re-balance rule and target
//
resource "aws_cloudwatch_event_rule" "ec2_instance_rebalance" {
  name = format("eks-%s-ec2-instance-rebalance", var.cluster_name)
  description = "Capture EC2 instance re-balance events"

  event_pattern = <<EOF
{
    "source": ["aws.ec2"],
    "detail-type": [
        "EC2 Instance Rebalance Recommendation"
    ]
}
EOF
}

resource "aws_cloudwatch_event_target" "ec2_instance_rebalance" {
    target_id = "ec2-instance-rebalance-event-target"
    rule = aws_cloudwatch_event_rule.ec2_instance_rebalance.name
    arn = aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.arn
}

//
// 
//
module "node_termination_handler_chart_values_yaml" {
    source = "./modules/node-termination-handler-chart-values"

    region = var.region
    cluster_name = var.cluster_name
    node_termination_handler_service_account_name = var.node_termination_handler_service_account_name
    node_termination_handler_service_account_iam_role_arn = module.node_termination_handler_iam_assumable_role_admin.this_iam_role_arn
    node_termination_handler_queue_url = aws_sqs_queue.lifecycle_hook_scale_in_notification_sqs.id
}

module "node_termination_handler_iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = var.node_termination_handler_service_account_iam_role_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.node_termination_handler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.node_termination_handler_service_account_namespace}:${var.node_termination_handler_service_account_name}"]
}

data "aws_iam_policy_document" "node_termination_handler" {
  statement {
    effect = "Allow"

    actions = [
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstances",
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "node_termination_handler" {
  name_prefix = "node-termination-handler"
  description = "EKS node-termination-handler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.node_termination_handler.json
}

