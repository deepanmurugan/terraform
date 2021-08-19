resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_to_cw"
  role = aws_iam_role.iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": "cloudwatch:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1576862112324",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
 EOF
}

resource "aws_iam_role" "iam_role" {
  name = "lambda_to_cw_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "cloudwatch_dashboard.zip"
  function_name    = "cloudwatch_dashboard"
  role             = aws_iam_role.iam_role.arn
  handler          = "lambda_function.cw_lambda"
  source_code_hash = filebase64sha256("cloudwatch_dashboard.zip")
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory
}

resource "aws_cloudwatch_event_rule" "cw_rule" {
  name        = "instance_state_change"
  description = "Monitor EC2 state change notifications and trigger lambda function"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "terminated",
      "pending",
      "stopped"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "cw_target" {
  rule      = aws_cloudwatch_event_rule.cw_rule.name
  target_id = "test_lambda"
  arn       = aws_lambda_function.test_lambda.arn
}

resource "aws_lambda_permission" "cwrule_permission" {
  statement_id  = "allow_lambda_cwrule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw_rule.arn
}
