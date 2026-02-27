data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = [var.codebuild_project_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticbeanstalk:CreateApplicationVersion",
      "elasticbeanstalk:DescribeApplicationVersions",
      "elasticbeanstalk:UpdateEnvironment",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticbeanstalk:DescribeEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [
      var.codebuild_role_arn,
      var.eb_service_role_arn,
      var.eb_ec2_role_arn
    ]
  }
}

resource "aws_iam_role_policy" "inline" {
  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}