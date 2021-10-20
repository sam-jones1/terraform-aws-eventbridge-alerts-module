variable "sns_topic_arn" {
  type        = string
  description = "The arn of the SNS topic to send the alert to"
}

variable "sqs_queue_arn" {
  type        = string
  description = "The arn of the SQS queue to use as the dead letter queue"
}

variable "aws_region" {
  type        = string
  description = "The region to deploy the alerts to"
  default     = "eu-west-2"
}

variable "event_rule_name" {
  type        = string
  description = "The name of the event rule"
}

variable "event_pattern" {
  type        = string
  description = "The event rule pattern to check"
}