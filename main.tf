data "aws_iam_policy_document" "bucket_policy" {
  statement {

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }

}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = local.bucket_name
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  tags = local.common_tags

  website = {

    index_document = "index.html"
    error_document = "error.html"

  }

}

module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = "static-website"
  template_vars = {
    # Pass in any values that you wish to use in your templates.
    vpc_id = "vpc-abc123"
  }
}

module "s3-bucket_object" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version = "4.1.2"

  for_each     = module.template_files.files
  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.key
  file_source  = each.value.source_path
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

data "aws_route53_zone" "selected" {
  name = "sctp-sandbox.com."
}

resource "aws_route53_record" "tsanghan-ce6" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.bucket_name
  type    = "A"

  alias {
    name                   = module.s3_bucket.s3_bucket_website_domain
    zone_id                = module.s3_bucket.s3_bucket_hosted_zone_id
    evaluate_target_health = false
  }

}
