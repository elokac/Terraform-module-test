variable "vpc_id" {}

variable "instance_type" {
  default = "t2-micro"
}
variable "subnet_id" {}

variable "key_name" {
  default = "test-key"
}

variable "bastion-ami" {
  default = "ami-053b0d53c279acc90"
}

variable "resource_tags" {
  description = "Tags to apply to resources created by the module."
  type        = map(string)
  default     = {}
}