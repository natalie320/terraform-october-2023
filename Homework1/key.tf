resource "aws_key_pair" "my_key" {
  public_key = file("~/.ssh/id_rsa.pub")
}

output "public_key" {
    value = aws_key_pair.my_key.public_key

}