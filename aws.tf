
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region = "us-west-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_ecs_cluster" "default" {
  name = "ednonlineeditor"
}

resource "aws_ecs_service" "ednonlineeditor_service" {
  name            = "ednonlineeditor-service"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.ednonlineeditor-task.arn}"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "ednonlineeditor-task" {
  family = "ednonlineeditor"
  container_definitions = "${file("task-definitions/ednonlineeditor.json")}"
  volume {
    name = "ednonlineeditor-home"
    host_path = "/ecs/ednonlineeditor-home"
  }
}

resource "aws_iam_role" "ednonlineeditor" {
    name = "ednonlineeditor"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ednonlineeditor" {
    name = "ednonlineeditor"
    path = "/"
    description = "ednonlineeditor"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ednonlineeditor" {
    name = "ednonlineeditor"
    roles = ["${aws_iam_role.ednonlineeditor.name}"]
    policy_arn = "${aws_iam_policy.ednonlineeditor.arn}"
}

resource "aws_iam_instance_profile" "ednonlineeditor" {
    name = "ednonlineeditor"
    roles = ["${aws_iam_role.ednonlineeditor.name}"]
}

resource "aws_security_group" "ednonlineeditor" {
  name = "ednonlineeditor"
  description = "ednonlineeditor"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "edneditoronline-instance" {
  ami = "ami-bb473cdb"
  instance_type = "t2.small"
   security_groups = ["${aws_security_group.ednonlineeditor.name}"]
  iam_instance_profile = "ednonlineeditor"
  user_data = "#!/bin/bash\necho ECS_CLUSTER=ednonlineeditor >> /etc/ecs/ecs.config"
}

resource "aws_route53_zone" "main" {
  name = "edneditor.com"
}

resource "aws_route53_record" "main-ns" {
    zone_id = "${aws_route53_zone.main.zone_id}"
    name = "edneditor.com"
    type = "A"
    ttl = "300"
    records = [
        "${aws_instance.edneditoronline-instance.public_ip}"
    ]
}
