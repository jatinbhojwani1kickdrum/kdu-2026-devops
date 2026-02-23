output "website_cdn_url" {
  value = module.website.cloudfront_url
}


data "aws_region" "current" {}