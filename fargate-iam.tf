data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "fargate_execution" {
  name = "dlwb_fargate_execution_policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource : "*",
        Condition : {
          StringEquals : {
            "aws:sourceVpce" : "${aws_vpc_endpoint.dlwb_dkr_vpce.id}",
            "aws:sourceVpc" : "${aws_vpc.main.id}"
          }
        }
      },
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue"
        ],
        Resource : "*",
        Condition : {
          StringEquals : {
            "aws:sourceVpce" : "${aws_vpc_endpoint.secret_manager.id}",
            "aws:sourceVpc" : "${aws_vpc.main.id}"
          }
        }
      },
      # {
      #   Effect : "Allow",
      #   Action : [
      #     "*"
      #   ],
      #   Resource : "*",
      #   Condition : {
      #     StringEquals : {
      #       "aws:sourceVpce" : "vpce-0c4773bf65a6857b6",
      #       "aws:sourceVpc" : "vpc-02db6e58f44be0afa"
      #     }
      #   }
      # }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "fargate_execution" {
  name               = "dlwb_fargate_execution_role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate-execution" {
  role       = aws_iam_role.fargate_execution.name
  policy_arn = aws_iam_policy.fargate_execution.arn
}