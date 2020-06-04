// TODO: change how AWS Crendentials are stored use valut
provider "aws" {
  region     = var.aws_region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}

resource "aws_s3_bucket" "tf_code" {
  bucket        = "testing-bucket-liangchen323"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "tf_bucket"
  }
}