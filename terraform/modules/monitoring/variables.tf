variable "alert_email" {
  description = "Email address for budget and Lambda alarms"
  type        = string
}

variable "alert_sms" {
  description = "Phone number for SMS alerts (E.164 format)"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name to monitor for errors"
  type        = string
}
