ARC-AKS-TF

# GitHub Actions ARC on AKS - Infrastructure as Code

This repo deploys a scalable, auto-scaling GitHub Actions runner environment on AKS using ARC and Terraform.  
**Modules** for each major Azure/K8s resource, with backend state in Azure Storage.  
Runner ScaleSet is deployed via Kubernetes manifest.

## Steps

1. Create a GitHub App, fill details into variables.
2. `terraform init` & `terraform apply`
3. Set up your `kubectl` context to AKS.
4. `kubectl apply -f manifests/arc-autoscale-runner.yaml`
5. Test workflows targeting your scale set.

See modules and root configs for details.
