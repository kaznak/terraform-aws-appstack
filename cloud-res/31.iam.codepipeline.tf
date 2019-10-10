# -*- Mode: HCL; -*-

resource "aws_iam_role" "codepipeline" {
  name               = "${local.default_name}-codepipeline"
  path               = "/"
  description        = "IAM Role for Codepipeline of ${local.default_name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

resource "aws_iam_policy" "codepipeline" {
  name        = "${local.default_name}-codepipeline"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodePipeline"
  policy      =  data.aws_iam_policy_document.codepipeline_fullaccess.json
}

data "aws_iam_policy_document" "codepipeline_fullaccess" {
  statement {
    effect = "Allow"
    resources = [
      "*",
    ]
    actions = [
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:CreateDeployment",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      aws_s3_bucket.codex.arn,
      "${aws_s3_bucket.codex.arn}/*",
    ]
    actions = [
      "s3:List*",
      "s3:Put*",
      "s3:Get*",
    ]
  }
}

# data "aws_iam_policy_document" "codepipeline_fullaccess" {
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = ["iam:PassRole"]
#     condition {
#       test = "StringEqualsIfExists"
#       variable = "iam:PassedToService"
#       values = [
# 	"cloudformation.amazonaws.com",
# 	"elasticbeanstalk.amazonaws.com",
# 	"ec2.amazonaws.com",
# 	"ecs-tasks.amazonaws.com",
#       ]
#     }
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "codecommit:CancelUploadArchive",
#       "codecommit:GetBranch",
#       "codecommit:GetCommit",
#       "codecommit:GetUploadArchiveStatus",
#       "codecommit:UploadArchive",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "codedeploy:CreateDeployment",
#       "codedeploy:GetApplication",
#       "codedeploy:GetApplicationRevision",
#       "codedeploy:GetDeployment",
#       "codedeploy:GetDeploymentConfig",
#       "codedeploy:RegisterApplicationRevision",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "elasticbeanstalk:*",
#       "ec2:*",
#       "elasticloadbalancing:*",
#       "autoscaling:*",
#       "cloudwatch:*",
#       "s3:*",
#       "sns:*",
#       "cloudformation:*",
#       "rds:*",
#       "sqs:*",
#       "ecs:*",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "lambda:InvokeFunction",
#       "lambda:ListFunctions",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "opsworks:CreateDeployment",
#       "opsworks:DescribeApps",
#       "opsworks:DescribeCommands",
#       "opsworks:DescribeDeployments",
#       "opsworks:DescribeInstances",
#       "opsworks:DescribeStacks",
#       "opsworks:UpdateApp",
#       "opsworks:UpdateStack",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "cloudformation:CreateStack",
#       "cloudformation:DeleteStack",
#       "cloudformation:DescribeStacks",
#       "cloudformation:UpdateStack",
#       "cloudformation:CreateChangeSet",
#       "cloudformation:DeleteChangeSet",
#       "cloudformation:DescribeChangeSet",
#       "cloudformation:ExecuteChangeSet",
#       "cloudformation:SetStackPolicy",
#       "cloudformation:ValidateTemplate",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "devicefarm:ListProjects",
#       "devicefarm:ListDevicePools",
#       "devicefarm:GetRun",
#       "devicefarm:GetUpload",
#       "devicefarm:CreateUpload",
#       "devicefarm:ScheduleRun",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "servicecatalog:ListProvisioningArtifacts",
#       "servicecatalog:CreateProvisioningArtifact",
#       "servicecatalog:DescribeProvisioningArtifact",
#       "servicecatalog:DeleteProvisioningArtifact",
#       "servicecatalog:UpdateProduct",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "cloudformation:ValidateTemplate",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#     actions = [
#       "ecr:DescribeImages",
#     ]
#   }
# }
