terraform {
  backend "s3" {
    bucket = "sctp-ce6-tfstate"
    key    = "tsanghan-ce6-2024-07-06-staticweb-s3-with-route53.tfstate"
    region = "ap-southeast-1"
  }
}