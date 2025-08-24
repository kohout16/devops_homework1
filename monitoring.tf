
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "terraform-homework-instance"
}


# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.app_name}"
  retention_in_days = 7
  
  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ExampleApp/Performance", "ResponseTime", "Endpoint", "/api/users"],
            [".", ".", ".", "/api/orders"],
            [".", ".", ".", "/health"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Response Time by Endpoint"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ExampleApp/Performance", "RequestCount", "StatusCode", "200"],
            [".", ".", ".", "404"],
            [".", ".", ".", "500"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Request Count by Status Code"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ExampleApp/Performance", "RequestCount", "Endpoint", "/api/users"],
            [".", ".", ".", "/api/orders"],
            [".", ".", ".", "/health"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Request Count by Endpoint"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 6
        height     = 6
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", "i-0123456789abcdef0" ]
          ]
          period    = 300
          stat      = "Average"
          region    = "eu-central-1"
          title     = "EC2 CPU"
        }
      },
      {
        type       = "metric"
        x          = 6
        y          = 0
        width      = 6
        height     = 6
        properties = {
          metrics = [
            [ "CWAgent", "mem_used_percent", "InstanceId", "i-0123456789abcdef0" ]
          ]
          period    = 300
          stat      = "Average"
          region    = "eu-central-1"
          title     = "EC2 Memory"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.app_logs.name}'\n| fields @timestamp, level, message, correlationId\n| filter level = \"ERROR\"\n| sort @timestamp desc\n| limit 20"
          region  = var.aws_region
          title   = "Recent Errors"
          view    = "table"
        }
      }
    ]
  })
}

# IAM Role for EC2 to write to CloudWatch
resource "aws_iam_role" "cloudwatch_role" {
  name = "${var.app_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.app_name}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "${var.app_name}-cloudwatch-profile"
  role = aws_iam_role.cloudwatch_role.name
}
