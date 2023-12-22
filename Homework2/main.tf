data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
resource "aws_instance" "Homework-ec2" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Homework-sg.id]
  key_name = aws_key_pair.homework-key.key_name
  user_data = file("apache.sh")

tags = {
    Name = "Homework-ec2"
    }
}

# resource "aws_instance" "my-instance" {
#   ami = "ami-0ee4f2271a4df2d7d"
#   instance_type = "t2.micro"
#   key_name = "my-laptop-key"
# }

# resource "aws_security_group" "my-sg" {
#   name = "my-sg"
# }