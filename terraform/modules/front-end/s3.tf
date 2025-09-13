# Create S3 bucket for static website hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket = "jesusperez-cloud-engineer-resume"
}

# Enable static website configuration
resource "aws_s3_bucket_website_configuration" "resume_website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Enable object versioning
resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Allow CloudFront to access bucket contents
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.website_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# index.html
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/../../../frontend/index.html"
  content_type = "text/html"
}

# style.css
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "assets/css/style.css"
  source       = "${path.module}/../../../frontend/assets/css/style.css"
  content_type = "text/css"
}

# main.js
resource "aws_s3_object" "main_js" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "assets/js/main.js"
  source       = "${path.module}/../../../frontend/assets/js/main.js"
  content_type = "application/javascript"
}

