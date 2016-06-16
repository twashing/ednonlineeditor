
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

resource "aws_instance" "edneditoronline-instance" {
  ami = "ami-bb473cdb"
  instance_type = "t2.micro"
  user_data = "#!/bin/bash \n echo ECS_CLUSTER=ednonlineeditor >> /etc/ecs/ecs.config"
}
