output "red_team_public_ip" {
  description = "Public IP of the Red Team instance"
  value       = aws_instance.red_team[*].public_ip
}

output "red_team_private_ip" {
  description = "Private IP of the Red Team instance"
  value       = aws_instance.red_team[*].private_ip
}

output "blue_team_private_ip" {
  description = "Private IP of the Blue Team instance"
  value       = aws_instance.blue_team.private_ip
}