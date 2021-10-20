resource "aws_cloudwatch_event_rule" "event_rule" {
  name          = var.event_rule_name
  event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule                = aws_cloudwatch_event_rule.event_rule.name
  target_id           = "SendToSNS"
  arn                 = var.sns_topic_arn
  dead_letter_config  {
    arn = var.sqs_queue_arn
  }
}