awsRegion: ${region}

rbac:
  create: true
  serviceAccount:
    name: ${autoscaler_service_account_name}
    annotations:
      eks.amazonaws.com/role-arn: ${autoscaler_service_account_iam_role_arn}

autoDiscovery:
  clusterName: ${cluster_name}
  enabled: true

nodeSelector:
    # enforce that cluster autoscaler runs on an on-demand node, if we allowed
    # it to run on a spot we might lose the ability to scale up new nodes
    node.kubernetes.io/lifecycle: on-demand

