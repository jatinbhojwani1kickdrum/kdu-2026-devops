resource "aws_elastic_beanstalk_application" "this" {
  count = var.create_app ? 1 : 0
  name  = var.app_name
}