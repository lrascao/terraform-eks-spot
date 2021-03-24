# awsRegion If specified, use the AWS region for AWS API calls
awsRegion: ${region}

# enableSqsTerminationDraining If true, this turns on queue-processor mode which drains nodes when an SQS termination event is received
enableSqsTerminationDraining: true

# queueURL Listens for messages on the specified SQS queue URL
queueURL: ${node_termination_handler_queue_url}

# checkASGTagBeforeDraining  If true, check that the instance is tagged with "aws-node-termination-handler/managed" as the key before draining the node
checkASGTagBeforeDraining: true

serviceAccount:
  # Specifies whether a service account should be created
  create: yes
  # The name of the service account to use. If name is not set and create is true,
  # a name is generated using fullname template
  name: ${node_termination_handler_service_account_name}
  annotations:
    eks.amazonaws.com/role-arn: ${node_termination_handler_service_account_iam_role_arn}

