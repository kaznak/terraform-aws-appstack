# -*- Mode: HCL; -*-

terraform {
  backend "s3" {
    bucket  = "tfstate"
    key     = "appstack.tfstate"
    region  = "us-east-1"
    profile = "tfstate"
  }
}

############################################################################
provider "aws" {
  version = "~> 2.22"
  profile = "deploy"
  region  = "ap-northeast-1"
}

provider "aws" {
  alias   = "us-east-1"
  version = "~> 2.22"
  profile = "deploy"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "control"
  version = "~> 2.22"
  profile = "domain"
  region  = "ap-northeast-1"
}

provider "random" {
  version = "~> 2.1"
  alias   = "r"
}
