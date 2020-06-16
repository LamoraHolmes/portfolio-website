# Event Rule for Trigger the Kubernetes Pipeline if a merge to master happens

resource "aws_cloudwatch_event_rule" "codepipeline-kubernetes-master" {
  name        = "codepipeline-kubernetes-master"
  description = "Watches the Kubernetes Repo for changes in master"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "arn:aws:codecommit:eu-central-1:123456789:kubernetes"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "master"
    ]
  }
}
PATTERN

tags = {
    Name = "codepipeline-kubernetes-master"
    Created = "with Terraform"
}
}


# Event Target for the Cloudwatch Rule

resource "aws_cloudwatch_event_target" "kubernetes-pipeline-target" {
  role_arn  = aws_iam_role.kubernetes-cloudwatch-role.arn
  rule      = aws_cloudwatch_event_rule.codepipeline-kubernetes-master.name
  target_id = "kubernetes-pipeline-target"
  arn       = aws_codepipeline.kubernetes-pipeline.arn
}
