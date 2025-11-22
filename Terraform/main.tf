
provider "aws" {
    region = "us-east-1"
    profile = "default"
}

# assaigning Key Pair

resource "aws_key_pair" "chinna_key" {
    key_name = var.key_name
    public_key = var.public_key
  
}

# craeting VPC
resource "aws_vpc" "chinna_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = { Name = "chinna_vpc" }
  
}

# creating subnet
resource "aws_subnet" "chinna_subnet" {
    vpc_id = aws_vpc.chinna_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = { Name = "chinna_subnet" }
  
}
# cretaing Internet Gateway
resource "aws_internet_gateway" "chinna_igw" {
    vpc_id = aws_vpc.chinna_vpc.id
    tags = { Name = "chinna-igw" }
  
}
# creating Route Table
resource "aws_route_table" "chinna_rt" {
    vpc_id = aws_vpc.chinna_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.chinna_igw.id

    }
  
}

# associating Route Table to Subnet
resource "aws_route_table_association" "public_rta" {
    route_table_id = aws_route_table.chinna_rt.id
    subnet_id = aws_subnet.chinna_subnet.id
  
}

# Security Group for Jenkins-Util-Server
resource "aws_security_group" "jenkins_util_sg" {

    name = "jenkins-util-sg"
    description = "sg for jenkins-util-server"
    vpc_id = aws_vpc.chinna_vpc.id

    ingress {
        description = "jenkins"
        from_port = 8080
        to_port = 8080
        protocol =  "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    ingress {
        description = "SonarQube"
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "ping"
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "outbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "jenkins-util-sg" }
  
}

## Security Group for App-Server
resource "aws_security_group" "MyApp_sg" {

    name = "MyApp-sg"
    description = "sg for MyApp-server"
    vpc_id = aws_vpc.chinna_vpc.id

    ingress {
        description = "MyApp port"
        from_port = 8080
        to_port = 8080
        protocol =  "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    ingress {
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "All Inbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "All outbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "MyApp-sg" }
}

# Creating Jenkins Instance
resource "aws_instance" "jenkins_util" {
    ami = "ami-0fa3fe0fa7920f68e"
    key_name = aws_key_pair.chinna_key.key_name
    subnet_id =  aws_subnet.chinna_subnet.id
    instance_type = "t3.large"
    vpc_security_group_ids = [aws_security_group.jenkins_util_sg.id]

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }

    provisioner "remote-exec" {
        inline = [
      "sudo yum update -y",
      "sudo yum install wget git maven ansible docker -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins && sudo systemctl start jenkins",
      "sudo systemctl enable docker && sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "sudo usermod -aG docker jenkins",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo docker run -d --name sonar -p 9000:9000 sonarqube",
      "sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.rpm"
         ]
    }

    tags = { Name = "jenkins-util-server" }
  
}

# Creating MyApp Server
resource "aws_instance" "MyApp_server" {
    ami = "ami-0fa3fe0fa7920f68e"
    key_name = aws_key_pair.chinna_key.key_name
    instance_type = "t3.micro"
    subnet_id = aws_subnet.chinna_subnet.id
    vpc_security_group_ids = [ aws_security_group.MyApp_sg.id ]

    tags = { Name = "MyApp-server" }

  
}