There are two options available for deploying static website.
1. Build a full CICD pipeline using Terraform and Jenkins deploy game source code to AWS S3 bucket + Cloudfront (edge location for global users)


2. Build a full CICD pipeline using Ansible, Terraform and Jenkins deploy game source code to AWS EC2 instances

### Jenkins
```
find /usr/lib/jvm/java-1.8* | head -n 3
vim ~/.bash_profile -> add java path
java -version -> java-1.8+
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins
systemctl start jenkins
systemctl enable jenkins
// Get Jenkins password
cat /var/lib/jenkins/secrets/initialAdminPassword
Install suggest plugins
Create user
Create a freestyle project named: Dicegame
Source Code Management: Git
Repository URL: https://github.com/LiangChen0323/DiceGame_Project
Create a Personal access token on Github for webhook use
Add Personal access token to Jenkins configuration -> GitHub -> GitHub server -> Add (secret text)-> tick Manage hooks
Check github repo: weebhooks
install Pipeline: AWS Steps 1.41 plugin on Jenkins (interaction between Jenkins and S3 bucket)
Add AWS Credential: AWScredentials
Delete old S3 bucket content and upload latest code using provided AWS credential:
withAWS(region:'eu-west-2', credentials: "AWScredentials") {
  s3Delete(bucket:"testing-bucket-liangchen323",path:"/*")
  s3Upload(bucket:"testing-bucket-liangchen323",file:"DiceGame")
}
Add stages for trigger Terraform
```

### Terraform
```
Create main.tf variable.tf terraform.tfvars
// TODO: change how AWS Crendentials are stored use valut
// TODO: ADD A record to AWS Route 53
provider "aws" {
  region     = var.aws_region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}

resource "aws_s3_bucket" "tf_code" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
  tags = {
    Name = "tf_bucket"
  }
}

locals {
    s3_origin_id = "S3-${var.bucket_name}"
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/${var.bucket_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.tf_code.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
    origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${var.bucket_name}.s3.amazonaws.com"
    prefix          = "myprefix"
  }

  # aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0 
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

### Ansible
```
```
