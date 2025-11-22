
variable "key_name" {

    description = "Name of the key"
    default = "chinna-key"
    type = string

}

variable "public_key" {

    description = "Name of the key"
    default = ""
    type = string

}

variable "vpc_cidr_block" {
    description = "CIDR block range for VPC"
    default = "10.81.0.0/16" 
}

variable "subnet_cidr_block" {
    description = "CIDR block range for subnet"
    default = "10.81.4.0/24"
  
}

variable "availability_zone" {
    description = "availibility zone for subnet"
    default = "us-east-1a"
  
}
