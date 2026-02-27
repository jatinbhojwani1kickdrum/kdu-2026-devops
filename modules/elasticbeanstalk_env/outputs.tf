output "cname" {
  value = aws_elastic_beanstalk_environment.this.cname
}

output "eb_service_role_arn" {
  value = aws_iam_role.eb_service_role.arn
}

output "eb_ec2_role_arn" {
  value = aws_iam_role.eb_ec2_role.arn
}