#######################################################
# GET DATA FROM AN AWS ROUTE53 ZONE                   #
#######################################################
data "aws_route53_zone" "cloudacia" {
  name         = var.domain_name
  private_zone = false

  provider = aws.virginia
}

#######################################################
# CNAME record for validating server SSL certificate  #
#######################################################
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.web_server.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cloudacia.zone_id
}

###############################################
#  AWS ROUTE53 CNAME RECORD                   #
###############################################
resource "aws_route53_record" "dns_record1" {
  zone_id = data.aws_route53_zone.cloudacia.zone_id
  name    = "www.${data.aws_route53_zone.cloudacia.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

#######################################################
# ADD DNS RECORD TYPE A WITH ALIAS cloudacia.net      #
#######################################################
resource "aws_route53_record" "dns_record2" {
  zone_id = data.aws_route53_zone.cloudacia.zone_id
  name    = data.aws_route53_zone.cloudacia.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
