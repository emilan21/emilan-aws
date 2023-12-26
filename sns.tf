resource "aws_sns_topic" "cloudwatch_metric_alarms" {
  name = "cloudwatch-metric-alarms"
}

resource "aws_sns_topic_subscription" "cloudwatch_metric_alarms_email_target" {
  topic_arn = aws_sns_topic.cloudwatch_metric_alarms.arn
  protocol  = "email"
  endpoint  = "emilan+cloudwatch-metric-alarms@ericmilan.dev"
}

resource "aws_sns_topic_subscription" "cloudwatch_metric_alarms_pagerduty_target" {
  topic_arn = aws_sns_topic.cloudwatch_metric_alarms.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/7da695445fb04d09c07491337b9e94ab/enqueue"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.cloudwatch_metric_alarms.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudwatch_metric_alarms.arn]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
