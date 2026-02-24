output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}