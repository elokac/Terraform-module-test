resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for the DB instance"
  vpc_id      = aws_vpc.new-test.id

  # Define rules to allow access from your private subnet(s)
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.database-subnet1.cidr_block,
    aws_subnet.database-subnet2.cidr_block]
    security_groups = [aws_security_group.bastion-sg.id]
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name = "mydb-subnet-group"
  subnet_ids = [aws_subnet.database-subnet1.id,
    aws_subnet.database-subnet2.id,
  aws_subnet.bastion-subnet.id]
  tags = {
    Name = "My DB Subnet Group"
  }
}


resource "aws_db_instance" "mydb_instance" {
  allocated_storage           = 20
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "8.0.33"
  instance_class              = "db.t2.micro"
  db_name                     = "mydb"
  username                    = "your_db_username"
  password                    = "your_db_password"
  db_subnet_group_name        = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.db_security_group.id]
  multi_az                    = false
  availability_zone           = "us-east-1a"
  identifier                  = "prophius-database"
  ca_cert_identifier          = "rds-ca-rsa4096-g1"
  allow_major_version_upgrade = true
  apply_immediately           = true
  skip_final_snapshot         = true

  # Configure CloudWatch Logs
  monitoring_interval                 = 60
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]
  iam_database_authentication_enabled = true
  performance_insights_enabled        = false
  monitoring_role_arn                 = aws_iam_role.test-IAM-Role-RDS.arn

  tags = {
    Name        = "${var.project}-DB"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "test-IAM-Role-RDS" {
  name = "test-IAM-Role-RDS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "test-IAM-Role-RDS"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_iam_policy_attachment" "test-IAM-Role-RDS-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  roles      = [aws_iam_role.test-IAM-Role-RDS.name]
  name       = "Policy for cloudwatch logs"
}