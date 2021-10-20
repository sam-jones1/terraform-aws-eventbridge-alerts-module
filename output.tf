output sqs_queue_arn {
  value = aws_sqs_queue.dlq.arn
}

output sns_topic_arn {
  value = aws_sns_topic.alert_topic.arn
}