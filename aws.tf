
variable "access_key" {}
variable "secret_key" {}

resource "aws_iam_role" "ednonlineeditor" {
    name = "ednonlineeditor"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ednonlineeditor" {
  name = "ednonlineeditor"
  role = "${aws_iam_role.ednonlineeditor.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
        "ecs:*",
        "iam:*",
        "elasticloadbalancing:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

provider "aws" {
  region = "us-west-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_elb" "edneditoronline-elb" {
  name = "edneditoronline-elb"
  availability_zones = ["us-west-1a"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8000/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "edneditoronline-elb"
  }
}

resource "aws_ecs_cluster" "default" {
  name = "ednonlineeditor"
}

resource "aws_ecs_service" "ednonlineeditor_service" {
  name            = "ednonlineeditor-service"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.ednonlineeditor-task.arn}"
  desired_count   = 1
  iam_role = "${aws_iam_role.ednonlineeditor.arn}"
  depends_on = ["aws_iam_role_policy.ednonlineeditor"]
  load_balancer {
    elb_name = "${aws_elb.edneditoronline-elb.name}"
    container_name = "ednonlineeditor"
    container_port = 80
  }
}

resource "aws_ecs_task_definition" "ednonlineeditor-task" {
  family = "ednonlineeditor"
  container_definitions = "${file("task-definitions/ednonlineeditor.json")}"
  volume {
    name = "ednonlineeditor-home"
    host_path = "/ecs/ednonlineeditor-home"
  }
}

# resource "aws_ami" "edneditoronline-ami" {
#   name = "edneditoronline-ami"
#   root_device_name = "/dev/xvda"
#   ebs_block_device {
#     device_name = "/dev/xvda"
#     volume_size = 8
#   }
# }
# 
# resource "aws_instance" "edneditoronline-instance" {
#   ami = "${aws_ami.edneditoronline-ami.id}"
#   instance_type = "t1.micro"
# }
