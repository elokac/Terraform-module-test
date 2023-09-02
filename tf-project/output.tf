output "bastion-ip" {
  value = aws_instance.bastion.public_ip
}

output "MySQL_DB_name" {
  value = aws_db_instance.mydb_instance.db_name
}

output "MySQL_DB_domain" {
  value = aws_db_instance.mydb_instance.domain
}

output "MySQL_DB_endpoint" {
  value = aws_db_instance.mydb_instance.endpoint
}