resource "aws_cloudwatch_metric_alarm" "high_nginx_4xx" {
  alarm_name          = "HighNginx4XXRequests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when ALB sees >= 1 4XX request"
  alarm_actions       = [aws_sns_topic.nginx_alert.arn]

  dimensions = {
    LoadBalancer = "app/ecs-nginx-demo-alb/8689db3d5ccb1c53"
    TargetGroup  = "targetgroup/ecs-nginx-demo-tg/2e4e42c866f62b54"
  }
}


resource "aws_sns_topic" "nginx_alert" {
  name = "nginx-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.nginx_alert.arn
  protocol  = "email"
  endpoint  = "laz.jiri@gmail.com"  # your email
}