locals {
  region = "ap-southeast-1"

  bucket_name = "tsanghan-ce6-staticwebsite.sctp-sandbox.com"

  name = "tsanghan-ce6"

  common_tags = {
    Name = "${local.name}"
  }

}
