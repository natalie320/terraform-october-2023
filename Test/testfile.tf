resource "aws_iam_user" "lb" {
  name = "user1"

  tags = {
    tag-key = "tag-value"
  }
}