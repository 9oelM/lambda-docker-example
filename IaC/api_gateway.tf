resource "aws_api_gateway_rest_api" "hello" {
  description = "all APIs related to api.hello.com"
  name = "hello-api"
}

resource "aws_api_gateway_resource" "hello_eng" {
  path_part   = "hello" # later, you will want to add another path for /bonjour, and so on
  parent_id   = aws_api_gateway_rest_api.hello.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.hello.id
}

resource "aws_api_gateway_method" "hello_eng" {
  rest_api_id   = aws_api_gateway_rest_api.hello.id
  resource_id   = aws_api_gateway_resource.hello_eng.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "hello_eng" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function_container_image.this_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-hello.html
  # example: arn:aws:execute-api:{your-region}:{your-account-id}:{some-random-hash}/test-invoke-stage/GET/hello
  # omit slash before aws_api_gateway_resource.hello_eng.path because it has a preceding slash
  source_arn = "arn:aws:execute-api:{your-region}:{your-account-id}:${aws_api_gateway_rest_api.hello.id}/*/${aws_api_gateway_method.hello_eng.http_method}${aws_api_gateway_resource.hello_eng.path}"
}

resource "aws_api_gateway_integration" "hello_eng" {
  rest_api_id             = aws_api_gateway_rest_api.hello.id
  resource_id             = aws_api_gateway_resource.hello_eng.id
  http_method             = aws_api_gateway_method.hello_eng.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_function_container_image.this_lambda_function_invoke_arn
}

resource "aws_api_gateway_stage" "hello" {
  description   = "stage of all APIs related to api.hello.com. Right now we have dev only"
  deployment_id = aws_api_gateway_deployment.hello.id
  rest_api_id   = aws_api_gateway_rest_api.hello.id
  stage_name    = terraform.workspace
}

resource "aws_api_gateway_deployment" "hello" {
  rest_api_id = aws_api_gateway_rest_api.hello.id
  description = "deployment all APIs related to api.hello.com"

  triggers = {
    redeployment = timestamp()
    # https://github.com/hashicorp/terraform/issues/6613#issuecomment-322264393
    # or you can just use md5(file("api_gateway.tf")) to make sure that things only get deployed when they changed
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_base_path_mapping" "hello" {
 api_id      = aws_api_gateway_rest_api.hello.id
 stage_name  = terraform.workspace
 domain_name = aws_api_gateway_domain_name.hello.domain_name
}

module "cors" {
 source  = "squidfunk/api-gateway-enable-cors/aws"
 version = "0.3.1"
 allow_headers = [
   # default allowed headers
   "Authorization",
   "Content-Type",
   "X-Amz-Date",
   "X-Amz-Security-Token",
   "X-Api-Key",
   # custom allowed headers
   "x-my-custom-header",
 ]

 api_id          = aws_api_gateway_rest_api.hello.id
 api_resource_id = aws_api_gateway_resource.hello_eng.id
}