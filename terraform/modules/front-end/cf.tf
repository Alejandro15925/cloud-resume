resource "aws_cloudfront_origin_access_control" "oac" {
  name                            = "cf-oac"
  description                     = "OAC for accessing S3 bucket website"
  origin_access_control_origin_type = "s3"
  signing_behavior                = "always"
  signing_protocol                = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id = "s3-origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100" # Cheapest

  aliases = ["jesuscloud.tech", "www.jesuscloud.tech"]

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:730335394664:certificate/a6a932c6-a3a3-4a37-89dc-980feda3a2e2"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cloud-resume-distribution"
  }
}
