# modules/monitoring/variables.tf

variable "alert_email" {
  description = "Email address to receive budget and alarm notifications"
  type        = string
}

variable "alert_sms" {
  description = "Phone number to receive SMS notifications"
  type        = string
}

variable "lambda_function_name" {
  description = "Function name to track invocation errors"
  type        = string
}

