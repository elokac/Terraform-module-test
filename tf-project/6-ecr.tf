resource "aws_ecr_repository" "prophius-ecr" {
  name                 = "${lookup(var.environment, terraform.workspace)}-${var.project}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project}-ecr"
    createdby   = var.createdby
    project     = var.project
    environment = lookup(var.environment, terraform.workspace)

  }
}

data "external" "tags_of_most_recently_pushed_image" {
  program = [
    "aws", "ecr", "describe-images",
    "--repository-name", "${aws_ecr_repository.prophius-ecr.name}",
    "--query", "{\"tags\": to_string(sort_by(imageDetails, &imagePushedAt)[-1].imageTags)}",
    "--region", "${lookup(var.region, terraform.workspace)}"
  ]
}
