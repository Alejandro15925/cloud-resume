# SNS Topic for notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "cloud-resume-monitoring-topic"
}

# Email subscription
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SMS subscription
resource "aws_sns_topic_subscription" "sms_alert" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "sms"
  endpoint  = var.alert_sms
}

# Budget alarm
resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "3.00"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"


  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [var.alert_email]
  }
}

# Lambda error alarm
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-invocation-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 3600 # 1 hour
  statistic           = "Sum"
  threshold           = 1 # Trigger if there is at least one error
  alarm_description   = "Triggered when Lambda invocation errors > 0"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}
