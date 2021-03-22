data "template_file" "kube_ssm_agent" {
    template = file("${path.module}/kube-ssm-agent-daemonset-yaml.tpl")
    vars = {
     }
}

resource "local_file" "kube_ssm_agent_yaml" {
    filename = var.kube_ssm_agent_yaml
    file_permission = "644"
    content = data.template_file.kube_ssm_agent.rendered
}
