#EC2, AMI, and Key

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
resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")

}
resource "aws_instance" "web" {
 ami                         = data.aws_ami.amazon-linux-2.id
 associate_public_ip_address = true
 instance_type               = "t2.micro"
 subnet_id                   = aws_subnet.public1.id
 availability_zone           = "us-east-1a" 
 vpc_security_group_ids      = [aws_security_group.allow_tls.id]
 key_name                    = aws_key_pair.deployer.key_name
 

 tags = {
    Name = "group-1"
  }
}

#RDS Subnet Group

resource "aws_db_subnet_group" "rds_subnet_group" {
    name = "rds_subnet_group"
    subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

#RDS INSTANCE
resource "aws_db_instance" "my-db" {
  identifier           = "my-db"
  allocated_storage    = 20
  storage_type          = "gp2"
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "kaizen123"
  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "RDS Instance"
  }
}

#Security group for Database to allow traffic on port 3306

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Group-1 RDS SG"
  }
}