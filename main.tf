resource "aws_sqs_queue" "dlq" {
  name = local.sqs_queue_name
}

resource "aws_sqs_queue_policy" "dlq_policy" {
  queue_url = aws_sqs_queue.dlq.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.dlq.arn}"
    }
  ]
}
POLICY
}

resource "aws_sns_topic" "alert_topic" {
  name = local.sns_topic_name
}

resource "aws_sns_topic_policy" "alert_topic_policy" {
  arn = aws_sns_topic.alert_topic.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "snspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.alert_topic.arn}"
    }
  ]
}
POLICY
}

module "alerts" {
  for_each        = local.all_alerts

  source          = "./alerting"

  sns_topic_arn   = var.sns_topic_arn == null ? aws_sns_topic.alert_topic.arn : var.sns_topic_arn
  sqs_queue_arn   = var.sqs_queue_arn == null ? aws_sqs_queue.dlq.arn : var.sqs_queue_arn

  event_rule_name = each.key
  event_pattern   = each.value
}
