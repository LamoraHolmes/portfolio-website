provider "aws" {
    version = "2.65"  
    region  = "eu-central-1"
    access_key = "YOUR KEY"
    secret_key = "YOUR SECRET KEY"
}


terraform {
  backend "s3" {
    bucket   = "infra-pipeline-statefiles"
    key      = "infra"                                      # value will be replaced with the name of the app
    region   = "eu-central-1"
    access_key = "YOUR KEY"
    secret_key = "YOUR SECRET KEY"
  }
}
