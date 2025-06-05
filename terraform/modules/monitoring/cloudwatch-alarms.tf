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

# CloudWatch Alarm for Lambda Invocation Errors
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-invocation-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 3600 # Every hour
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when Lambda invocation errors > 0"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

# CloudWatch Alarm for Monthly Billing Projection
resource "aws_cloudwatch_metric_alarm" "monthly_cost_projection" {
  alarm_name          = "MonthlyCostProjection"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 43200 # Every 12 hours
  statistic           = "Maximum"
  threshold           = 3
  alarm_description   = "Triggered when projected monthly AWS costs exceed $3"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    Currency = "USD"
  }
}
