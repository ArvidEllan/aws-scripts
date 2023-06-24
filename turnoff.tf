provider "aws" {
  region = "us-east-1"  # Replace with your desired region
  access_key = "YOUR_ACCESS_KEY"
  secret_access_key = "YOUR_SECRET_ACCESS_KEY"
}

resource "aws_lambda_function" "scheduled_function" {
  function_name = "scheduled-function"
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "python3.8"
  timeout = 60  # Set an appropriate timeout value
  memory_size = 128  # Set an appropriate memory size

  filename = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

data "archive_file" "lambda_function" {
  type = "zip"
  source_dir = "lambda_code_directory"
  output_path = "lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name        = "scheduled_function_rule"
  description = "Trigger Lambda function on a schedule"
  schedule_expression = "cron(0 0 * * ? *)"  # Adjust the cron expression to define your schedule
}

resource "aws_cloudwatch_event_target" "schedule_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  arn       = aws_lambda_function.scheduled_function.arn
}
