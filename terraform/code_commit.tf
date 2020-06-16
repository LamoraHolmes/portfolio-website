resource "aws_codecommit_repository" "kubernetes" {
  repository_name = "kubernetes"
  description     = "Repo for the kubernetes code"
}