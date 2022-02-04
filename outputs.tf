output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.b-h_eip.public_ip
}

output "public_dns" {
  description = "Public DNS associated with the Elastic IP address"
  value       = aws_eip.b-h_eip.public_dns
}

output "public_rsa_key" {
  description = "public_rsa_key"
  value       = aws_ssm_parameter.public_rsa_key.value
}