output "vpc_id" {
  value = aws_vpc.new-test.id
}

output "bastion_subnet" {
  value = aws_subnet.bastion-subnet.id
}