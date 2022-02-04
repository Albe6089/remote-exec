output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.b-h_eip.public_ip
}

output "public_dns" {
  description = "Public DNS associated with the Elastic IP address"
  value       = aws_eip.b-h_eip.public_dns
}