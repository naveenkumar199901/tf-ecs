data "template_file" "signalfx" {
  count = "${var.enable_signalfx == "true" ? 1 : 0}"

  template = "${file("templates/tasks/signalfx.json")}"

  vars {
    api_key = "${var.signalfx_api_key}"
  }
}

resource "aws_ecs_task_definition" "signalfx" {
  count = "${var.enable_signalfx == "true" ? 1 : 0}"

  container_definitions = "${data.template_file.signalfx.rendered}"
  family                = "signalfx"

  volume {
    name      = "root"
    host_path = "/"
  }

  volume {
    name      = "docker"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "signalfx" {
  count = "${var.enable_signalfx == "true" ? 1 : 0}"

  cluster         = "tf-cluster"
  name            = "tf-cluster-signalfx"
  task_definition = "${aws_ecs_task_definition.signalfx.arn}"
  desired_count   = "1000"

  placement_constraints {
    type = "distinctInstance"
  }
}
