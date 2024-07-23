# cc-terraform-deploy-test

# Terraform
1. Use brew to install terraform
2. clone this repo
3. Create `terraform.tfvars` with the following contents.
For the purposes of this test, create a IAM role that has admin rights and grab the access key & secret key 
 ```
    aws_access_key  = "your-access-key"
    aws_secret_key  = "your-aws-secret-key"
    app_environment = "dev"
    env_file        = "dev.json"
    app_image_name  = "sriks2009/ccv2:latest"
    web_desired_count = 1
    web_fargate_cpu = 8192
    web_fargate_memory = 24576
    worker_desired_count = 1
    worker_fargate_cpu = 8192
    worker_fargate_memory = 24576
    aws_region = "us-west-1"```
4. `terraform init`
5. Create file `dev.json`. Ping me to get the file
5. `terraform apply` (accept yes on prompt) (to deploy)
6. `terraform destroy` (access yes on prompt) (to destroy instances)
7. CC should be deployed to your aws account. Adding Application load balancer is still todo right now.


NOTE: 
1. Ensure you destroy to make sure there's no aws charges
2. This will not work in 5/3 environment, but this is close enough!