output "tfe_asg_name" {
  description = "The name of the TFE Auto Scaling group."
  value       = aws_autoscaling_group.tfe.name
}

output "tfe_security_group_id" {
  description = "The Id of the AWS security group assigned to the TFE EC2 instances."
  value       = aws_security_group.tfe_instance.id
}