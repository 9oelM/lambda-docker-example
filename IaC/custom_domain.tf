resource "aws_acm_certificate" "hello" {
  provider          = aws.default_us_east_1
  domain_name       = "api.hello.com"
  validation_method = "DNS"

  tags = {
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "hello" {
  provider = aws.default_us_east_1

  certificate_arn         = aws_acm_certificate.hello.arn
  validation_record_fqdns = [for record in aws_route53_record.hello : record.fqdn]
}

locals {
  aws_route53_your_existing_zone_id = "A123A123A123A123"
}

resource "aws_route53_record" "hello" {
  for_each = {
    for dvo in aws_acm_certificate.hello.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.aws_route53_your_existing_zone_id
}

resource "aws_api_gateway_domain_name" "hello" {
 security_policy = "TLS_1_2"
 certificate_arn = aws_acm_certificate_validation.hello.certificate_arn
 domain_name     = aws_acm_certificate.hello.domain_name

 endpoint_configuration {
   types = ["EDGE"]
 }
}

resource "aws_route53_record" "custom_domain_to_cloudfront" {

 zone_id = local.aws_route53_your_existing_zone_id
 name    = "api.hello.com"
 type    = "CNAME"
 ttl     = "300"
 records = [aws_api_gateway_domain_name.hello.cloudfront_domain_name]
}