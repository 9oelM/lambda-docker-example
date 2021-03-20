resource "aws_ecr_repository" "hello" {
  name                 = "${terraform.workspace}-hello"
  image_tag_mutability = "MUTABLE" # you are going to be overwriting 'latest' tagged image.

  image_scanning_configuration {
    scan_on_push = true
  }

  depends_on = [aws_iam_role_policy_attachment.video]
}

data "aws_ecr_image" "latest" {
  repository_name = aws_ecr_repository.hello.name # from hello_role.tf
  image_tag       = "latest"
}
