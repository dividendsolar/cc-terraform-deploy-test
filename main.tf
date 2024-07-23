############CREATING A ECS CLUSTER#############

resource "aws_ecs_cluster" "crawlingchaos" {
  name = "crawlingchaos"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "local_file" "backend_conf" {
  filename = var.env_file
}

locals {
  env_data = jsondecode(file("${path.module}/${var.env_file}"))

  # get all vars
  all_vars = [for v in local.env_data.variables : {name = v.name
                                                   value = v.value}]

  boo = tolist([{"name" = "LIMITED_OPERATION_MODE"
                                     "value" = "true"}])
  # Limited operation mode
  # TODO: Fix CC to handle quartz
  limited_op_mode_vars = flatten([local.all_vars, tolist([{"name" = "LIMITED_OPERATION_MODE"
                                                           "value" = "true"}])])
}

# output "all_vars" {
#   value = local.all_vars
# }

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "awslogs-cc-web" {
  name = "awslogs-cc-web"

  tags = {
    Environment = "production"
    Application = "${var.app_environment}-web"
  }
}

resource "aws_cloudwatch_log_group" "awslogs-cc-worker" {
  name = "awslogs-cc-worker"

  tags = {
    Environment = "production"
    Application = "${var.app_environment}-worker"
  }
}

resource "aws_ecs_task_definition" "webtask" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = "${var.web_fargate_cpu}"
  memory                   = "${var.web_fargate_memory}"
  #task_role_arn            = "${var.ecs_task_role}"
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"  
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "${var.app_environment}-web",
      "image"     : "${var.app_image_name}",
      "cpu"       : ${var.web_fargate_cpu},
      "memory"    : ${var.web_fargate_memory},
      "essential" : true,
      "environment": ${jsonencode(local.limited_op_mode_vars)},   
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${aws_cloudwatch_log_group.awslogs-cc-web.id}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "${var.app_environment}-web",
            "mode": "non-blocking", 
            "max-buffer-size": "25m" 
        }
      },                                         
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort"      : 3000
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_task_definition" "workertask" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = "${var.worker_fargate_cpu}"
  memory                   = "${var.worker_fargate_memory}"
  #task_role_arn            = "${var.ecs_task_role}"
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"  
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "${var.app_environment}-worker",
      "image"     : "${var.app_image_name}",
      "cpu"       : ${var.worker_fargate_cpu},
      "memory"    : ${var.worker_fargate_memory},
      "essential" : true,
      "environment": ${jsonencode(local.limited_op_mode_vars)},   
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${aws_cloudwatch_log_group.awslogs-cc-worker.id}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "${var.app_environment}-worker",
            "mode": "non-blocking", 
            "max-buffer-size": "25m" 
        }
      },                                         
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort"      : 3000
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "web" {
  name             = "web"
  cluster          = aws_ecs_cluster.crawlingchaos.id
  task_definition  = aws_ecs_task_definition.webtask.id
  desired_count    = "${var.web_desired_count}"
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.subnet.id]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "worker" {
  name             = "worker"
  cluster          = aws_ecs_cluster.crawlingchaos.id
  task_definition  = aws_ecs_task_definition.workertask.id
  desired_count    = "${var.worker_desired_count}"
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.subnet.id]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}