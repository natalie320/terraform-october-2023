resource "aws_s3_bucket" "hello" {
  bucket_prefix = "kaizen-"
}

resource "aws_s3_bucket" "hello2" {
  bucket = "kaizen-hello-124"
}
