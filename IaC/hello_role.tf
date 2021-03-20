resource "aws_iam_role" "hello" {
  name = "hello_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          # this should be set as the 'default' user on your AWS cli.
          # get 'localtf' user's ARN from AWS IAM console
          # it should look like: arn:aws:iam::{aws-account-id}:user/localtf
          # example: arn:aws:iam::123456789:user/localtf
          "AWS" : "arn:aws:iam::123456789:user/localtf"
          "Service" : [
            "lambda.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "hello" {
  name        = "hello_policy"
  description = "policy needed to run hello server stack"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "lambda:*",
          "iam:*",
          "ecr:*",
          "cloudformation:*",
          "apigateway:*",
          "logs:*",
          "route53:*",
          "acm:*",
          "cloudfront:*",
          "ec2:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "hello" {
  role       = aws_iam_role.hello.name
  policy_arn = aws_iam_policy.hello.arn
}
