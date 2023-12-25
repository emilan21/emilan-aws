resource "aws_sns_topic" "cloudwatch_metric_alarms" {
  name = "cloudwatch-metric-alarms"
}

resource "aws_sns_topic_subscription" "cloudwatch_metric_alarms_email_target" {
  topic_arn = aws_sns_topic.cloudwatch_metric_alarms.arn
  protocol  = "email"
  endpoint  = "emilan+cloudwatch-metric-alarms@ericmilan.dev"
}
