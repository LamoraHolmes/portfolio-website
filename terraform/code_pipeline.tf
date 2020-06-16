resource "aws_codepipeline" "kubernetes-pipeline" {
  name     = "kubernetes-infra-pipeline"
  role_arn = aws_iam_role.kubernetes-pipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline-kubernetes.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        BranchName            = "master"
        RepositoryName        = "kubernetes"
        PollForSourceChanges  = false
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "Kubernets-Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.kubernetes-plan.arn
      }
    }
  }  

  stage {
    name = "Approve"

    action {
      name             = "Approve"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
    }
  }

  stage {
    name = "Apply"

    action {
      name             = "Kubernets-Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["plan_output"]
      output_artifacts = ["apply_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.kubernetes-apply.arn
      }
    }
  }  
}