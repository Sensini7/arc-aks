location   = "westus"
rg_name    = "arc-demo-rg"
aks_name   = "arcaksdemo"
dns_prefix = "arcaksdemo"
vm_size    = "Standard_B2s"
#vm_size   = "Standard_D2s_v4"
# github_app_id   = "123456"
# github_app_installation_id = "654321"
# github_app_private_key     = "<PEM CONTENTS>"

# GitHub configuration
github_config_url = "https://github.com/Sensini7/arc-aks"
runner_group      = "Default"
min_runners       = 0
max_runners       = 10
runner_image      = "ghcr.io/actions/actions-runner:latest"
arc_runner_release_name = "arc-runner-set"

# GitHub App credentials are still in github_app.auto.tfvars
# github_app_id   = "123456"
# github_app_installation_id = "654321"
# github_app_private_key     = "<PEM CONTENTS>"