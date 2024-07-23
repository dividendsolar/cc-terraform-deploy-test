# cc-terraform-deploy-test

# Terraform
1. Use brew to install terraform
2. clone this repo
3. Update `terraform.tfvars` with your AWS access keys
4. `terraform init`
5. Create file `dev.json`. Ping me to get the file
5. `terraform apply` (accept yes on prompt) (to deploy)
6. `terraform destroy` (access yes on prompt) (to destroy instances)
7. CC should be deployed to your aws account. Adding Application load balancer is still todo right now.


NOTE: Ensure you destroy to make sure there's no aws charges