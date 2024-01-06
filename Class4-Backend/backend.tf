terraform {
  backend "s3" {
    bucket = "ohiokaizen123"
    key    = "ohio/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "lock-state"
  }
}
