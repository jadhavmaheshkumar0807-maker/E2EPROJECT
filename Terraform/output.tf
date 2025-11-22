
output "public_ip_jenkins" {
  description = "Public IP of the jenkins-util server"
  value = aws_instance.jenkins_util.public_ip
}

output "public_dns_jenkins" {
  description = "Public dns of the jenkins-util server"
  value = aws_instance.jenkins_util.public_dns
}

output "public_ip_MyApp" {
  description = "Public IP of the MyApp server"
  value = aws_instance.MyApp_server.public_ip
}

output "public_dns_MyApp" {
  description = "Public dns of the MyApp server"
  value = aws_instance.MyApp_server.public_dns
}