# Create an AWS DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

# Create an AWS S3 bucket for storing Terraform state files
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "proph-${random_id.example.hex}"                

}

resource "random_id" "example" {
  byte_length = 8
}

# resource "aws_s3_bucket_acl" "example" {
#   bucket = aws_s3_bucket.terraform_state_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Output values for configuring Terraform backend
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state_bucket.bucket
}

output "s3_bucket_name_id" {
  value = aws_s3_bucket.terraform_state_bucket.id
}
