variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

# VPC configuration variables
variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Availability zones configuration variable
variable "availability_zones" {
  description = "AWS availability zones to use"
  type        = string
  default     = "us-west-1a"
}

variable "env_file" {
  description = "A file to be passed to ECS as environment variables."
  type        = string
}

variable "worker_desired_count" {
  description = "Number of desired worker nodes to create"
  type        = number
}

# Look in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "worker_fargate_cpu" {
  description = "Required cpu for worker nodes"
  type        = number
}

variable "worker_fargate_memory" {
  description = "Required memory for worker nodes"
  type        = number
}


variable "web_desired_count" {
  description = "Number of desired web nodes to create"
  type        = number
}

# Look in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "web_fargate_cpu" {
  description = "Required cpu for web nodes"
  type        = number
}

variable "web_fargate_memory" {
  description = "Required memory for web nodes"
  type        = number
}

variable "app_image_name" {
  description = "Docker image name for both web and worker nodes"
  type        = string
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}