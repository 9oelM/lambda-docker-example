module "lambda_function_container_image" {
  version = "1.43.0"
  source  = "terraform-aws-modules/lambda/aws"

  function_name = "${terraform.workspace}-HelloEngFunction"
  description   = "GET /hello"

  create_package = false

  # this will allow Terraform to detect changes in the docker image because
  # a new image will have a different SHA (digest).
  image_uri    = "{your-account-id}.dkr.ecr.{your-region}.amazonaws.com/${aws_ecr_repository.hello.name}@${data.aws_ecr_image.latest.image_digest}"
  package_type = "Image"
}
