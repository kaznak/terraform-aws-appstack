# -*- Mode: HCL; -*-

## EC2 : S3 CodeX ########################################################
resource "aws_iam_role_policy_attachment" "ec2_s3_codex" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_codex.arn
}

## EC2 : ClowdWatch ########################################################
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.cloud_watch_agent_server_policy.arn
}

data "aws_iam_policy" "cloud_watch_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
