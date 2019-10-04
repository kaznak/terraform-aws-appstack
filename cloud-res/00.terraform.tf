# -*- Mode: HCL; -*-

terraform {
  required_version = "~> 0.12.0"
  required_providers {
    tls    = "~> 2.0"
    local  = "~> 1.2"
    aws    = "~> 2.12"
    random = "~> 2.1"
  }
  backend "s3" {
    bucket  = "tfstate"
    key     = "appstack.tfstate"
    region  = "us-east-1"
    profile = "tfstate"
  }
}

############################################################################
provider "aws" {
  profile = "deploy"
  region  = "ap-northeast-1"
}

provider "aws" {
  alias   = "us-east-1"
  profile = "deploy"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "control"
  profile = "domain"
  region  = "ap-northeast-1"
}

provider "random" {
  alias   = "r"
}
