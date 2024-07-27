locals {
	client_s3_origin_id = "node-boilerplate.bitkitchen.org.s3.eu-central-1.amazonaws.com"
	backend_origin_id = "${var.app_name}-backend"
}

data "aws_ssm_parameter" "apigw_id" {
  name  = "/config/${var.app_name}/apigw-id"
}

data "aws_acm_certificate" "node_boilerplate" {
	provider = aws.global
	domain   = var.acm_cert_domain
}

data "aws_s3_bucket" "client_bucket" {
    bucket = var.app_domain_name
}

resource "aws_cloudfront_origin_access_control" "node_boilerplate" {
  name                              = "${var.app_domain_name}.s3.eu-west-1.amazonaws.com"
  description                       = "node-boilerplate origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "default" {
  name        = "default-policy"
  default_ttl = 50
  max_ttl     = 100
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

data "aws_cloudfront_cache_policy" "apigw" {
	name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "apigw" {
	name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_cache_policy" "s3" {
	name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3" {
	name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}

resource "aws_cloudfront_distribution" "node_boilerplate" {

  origin {
    domain_name              = data.aws_s3_bucket.client_bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.node_boilerplate.id
    origin_id                = local.client_s3_origin_id
  }

  origin {
    domain_name              = "${data.aws_ssm_parameter.apigw_id.value}.execute-api.eu-west-1.amazonaws.com"
    origin_id                = local.backend_origin_id
		custom_origin_config {
			http_port              = 80
			https_port             = 443
			origin_protocol_policy = "https-only"
			origin_ssl_protocols   = ["TLSv1.2"]
		}
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "var.app_domain_name"
  # }

  aliases = [var.app_domain_name]
	price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.client_s3_origin_id

    cache_policy_id = aws_cloudfront_cache_policy.default.id

    viewer_protocol_policy = "allow-all"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.backend_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.apigw.id
		origin_request_policy_id = data.aws_cloudfront_origin_request_policy.apigw.id

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/login"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.backend_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.apigw.id
		origin_request_policy_id = data.aws_cloudfront_origin_request_policy.apigw.id

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/oidc-callback*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.backend_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.apigw.id
		origin_request_policy_id = data.aws_cloudfront_origin_request_policy.apigw.id

    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.client_s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.s3.id
		origin_request_policy_id = data.aws_cloudfront_origin_request_policy.s3.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.node_boilerplate.arn
		minimum_protocol_version = "TLSv1.2_2021"
		ssl_support_method  = "sni-only"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_access_from_cf_distribution" {
  bucket = data.aws_s3_bucket.client_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cf_distribution.json
}

data "aws_iam_policy_document" "allow_access_from_cf_distribution" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

		effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.client_bucket.arn}/*",
    ]

		condition {
      test     = "ForAnyValue:StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.node_boilerplate.id}"]
    }
  }
}

data "aws_route53_zone" "primary" {
  name = "bitkit.click"
}

resource "aws_route53_record" "node_boilerplate" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = replace(var.app_domain_name, "/([a-z-]+)[.].+/", "$1")
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.node_boilerplate.domain_name
    zone_id                = aws_cloudfront_distribution.node_boilerplate.hosted_zone_id
    evaluate_target_health = false
  }
}
