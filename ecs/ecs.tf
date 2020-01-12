# Create ECS cluster - Basically Auto Scaling group of EC2
resource "aws_ecs_cluster" "test-ecs-cluster" {
    name = "${var.ecs_cluster}"
}

# Create ECS Task definition
data "aws_ecs_task_definition" "test" {
task_definition = "${aws_ecs_task_definition.test.family}"
depends_on = ["aws_ecs_task_definition.test"]
}

# Define container parameters
resource "aws_ecs_task_definition" "test" {
family = "test-family"
container_definitions = <<DEFINITION
[
  { 
    "name": "nginx",
    "image": "nginx:latest",
    "memory": 128,
    "cpu": 128,
    "essential": true,
    "portMappings": [
      {
        "hostPort": 0,
        "containerPort": 80,
        "protocol": "tcp"
      }
    ] 
  } 
]
DEFINITION
}

# Create ECS service to run and manage the tasks
resource "aws_ecs_service" "test-ecs-service" {
name = "test-vz-service"
cluster = "${aws_ecs_cluster.test-ecs-cluster.id}"
task_definition = "${aws_ecs_task_definition.test.family}:${max("${aws_ecs_task_definition.test.revision}", "${data.aws_ecs_task_definition.test.revision}")}"
desired_count = "${var.ecs_desired_count}" 
iam_role = "${aws_iam_role.ecs-service-role.name}"
load_balancer {
target_group_arn = "${aws_alb_target_group.ecs-target-group.id}"
container_name = "nginx"
container_port = "80"
}
ordered_placement_strategy {
  type = "spread"
  field = "instanceId"
}
depends_on = [ "aws_alb_listener.alb-listener" ]
}
