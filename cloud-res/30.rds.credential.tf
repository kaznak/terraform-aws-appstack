# -*- Mode: HCL; -*-

resource "random_string" "username" {
  provider = random.r
  length   = 16
  special  = false
  number   = false
}

resource "random_string" "password" {
  provider = random.r
  length   = 32
  special  = false
}
