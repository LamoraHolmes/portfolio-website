# Codebuild for Planning the Kubernetes Apply Command

resource "aws_codebuild_project" "kubernetes-plan" {
  name          = "kubernetes-plan"
  description   = "Makes the kubernetes dry run"
  build_timeout = "60"
  service_role  = aws_iam_role.kubernetes-build-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/ubuntu-base:14.04"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "Status"
      value = "Plan"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "Account"
      value = "675726544913"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "Stage"
      value = "Dev"
      type  = "PLAINTEXT"
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id              = aws_vpc.main-vpc.id
    subnets             = ["${aws_subnet.private-subnet.id}"]
    security_group_ids  = ["${aws_security_group.allow-vpc-traffic.id}"]
  }

  source_version = "master"

  tags = {
    Name = "Kubernetes Plan"
    Created = "with Terraform"
  }
}

# Codebuild for Applying the Kubernetes Changes

resource "aws_codebuild_project" "kubernetes-apply" {
  name          = "kubernetes-apply"
  description   = "Makes the kubernetes apply"
  build_timeout = "60"
  service_role  = aws_iam_role.kubernetes-build-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/ubuntu-base:14.04"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "Status"
      value = "Apply"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "Account"
      value = "123456789"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "Stage"
      value = "Dev"
      type  = "PLAINTEXT"
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id              = aws_vpc.main-vpc.id
    subnets             = ["${aws_subnet.private-subnet.id}"]
    security_group_ids  = ["${aws_security_group.allow-vpc-traffic.id}"]
  }


  source_version = "master"

  tags = {
    Name = "Kubernetes Plan"
    Created = "with Terraform"
  }
}
