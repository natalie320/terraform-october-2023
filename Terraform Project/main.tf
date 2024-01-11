provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "group-1"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a" 
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet3"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "a-private" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "b-public" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "c-public" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public.id
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  
  }

  owners = ["137112412989"] 
}

resource "aws_instance" "web" {
 depends_on = [aws_internet_gateway.gw]



 ami                         = data.aws_ami.amazon-linux-2.id
 associate_public_ip_address = true
 instance_type               = "t2.micro"
 subnet_id = aws_subnet.subnet2.id
 vpc_security_group_ids = [aws_security_group.allow_tls.id]
 key_name = aws_key_pair.deployer.key_name
 

 tags = {
    Name = "group-1"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, ]

}

resource "null_resource" "cluster" {
  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    host = element(aws_instance.web[*].public_ip, 0)
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
  
    inline = [
        "sudo yum install httpd -y",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd",
        "sudo yum install git -y"
    ]
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "group-1"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "RDS security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  identifier           = "wordpress-db-instance"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  username             = "dbadmin"
  password             = "kaizen123"
  publicly_accessible = false
  skip_final_snapshot  = false
}