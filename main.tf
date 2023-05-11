terraform{
  # Configure the AWS Provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
  cloud {
    organization = "rdcresume"

    workspaces {
      name = "resume-frontend"
    }
  }
}

# Configure the S3 bucket
resource "aws_s3_bucket" "crchost2" {
  bucket = "crchost2"
}

# Setting up bucket ownership
resource "aws_s3_bucket_ownership_controls" "open" {
  bucket = aws_s3_bucket.crchost2.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Configure the bucket to be publicly accessible
resource "aws_s3_bucket_public_access_block" "publicAccess" {
  bucket = aws_s3_bucket.crchost2.id

  block_public_policy     = false
  restrict_public_buckets = false
}

# Adding the file to the S3 bucket
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.crchost2.id
  key    = "Resume.html"
  source = "${path.module}/BucketItems/Resume.html"
  content_type = "text/html"
}

# Configuring bucket to host a static website
resource "aws_s3_bucket_website_configuration" "Resume" {
  bucket = aws_s3_bucket.crchost2.id

  index_document {
    suffix = "Resume.html"
  }
}

# Policy to allow objects in bucket to be open to the public
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.crchost2.id
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.crchost2.id}/*"
        }
    ]
  }
  POLICY
}