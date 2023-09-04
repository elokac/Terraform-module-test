
variable "cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "proph-vpc"
}

variable "project" {
  default = "proph"
}

variable "public-subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "public-subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "private-subnet1_cidr" {
  default = "10.0.3.0/24"
}

variable "private-subnet2_cidr" {
  default = "10.0.4.0/24"
}

variable "db-subnet1_cidr" {
  default = "10.0.5.0/24"
}

variable "db-subnet2_cidr" {
  default = "10.0.6.0/24"
}

variable "bastion-subnet-cidr" {
  default = "10.0.7.0/24"
}

variable "manager" {
  type = list(string)
  default = [
    "terraform",
    "cloudformation",
    "console"
  ]
}

variable "createdby" {
  default = "eloka.chiejina"
}

variable "environment" {
  default = {
    default = "dev"
    stage   = "stage"
    prod    = "prod"
  }
}