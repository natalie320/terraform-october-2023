resource "aws_db_instance" "wordpress" {
  engine           = "mysql"
  instance_class   = "db.t2.micro"
  allocated_storage = 20
  identifier = "${var.stack}-rds"
  db_name          = var.dbname
  username         = var.username
  password         = var.password  
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  # backup_retention_period = 5
  engine_version = "5.7"
  apply_immediately = true
  # final_snapshot_identifier = "wordpress"  # it is needed when you want it to have backup and publ_acc should be false then
  skip_final_snapshot = true
  iam_database_authentication_enabled = true
  publicly_accessible = true
  multi_az = true
  tags = {
    Name = "wordpress-rds"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "${var.stack}-key"
  public_key = file(var.ssh_key)
  }

data "aws_ami" "amazon" {
  most_recent = true
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_instance" "wordpress" {
  ami           = "${data.aws_ami.amazon.id}"                     
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name  
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id = aws_subnet.public1.id
  

  tags = {
    Name = "${var.stack}-ec2"
  }
  connection {
    host = element(aws_instance.wordpress[*].public_ip, 0)
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.ssh_priv_key)
    
  }
  provisioner "remote-exec" {
    inline = [
      # "sudo yum update -y",
      # "sudo yum install httpd wget unzip php php-mysqli -y",
      # "sudo systemctl start httpd",
      # "sudo systemctl enable httpd",
      # "wget https://wordpress.org/latest.tar.gz",
      # "tar -xf latest.tar.gz",
      # "sudo chown -R apache:apache /var/www/html/",
      # "sudo cp -R wordpress/*  /var/www/html/",
      # "sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm",
      # "sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y",
      # "sudo dnf install mysql-community-server -y",
      # "sudo systemctl start mysqld && sudo systemctl enable mysqld"
# belowing for linux2
      "sudo yum update -y",
      "sudo yum install httpd wget unzip php -y",
      "sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2",
      "sudo yum install mariadb-server -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "wget https://wordpress.org/latest.tar.gz",
      "tar -xf latest.tar.gz",
      "sudo mv latest.tar.gz wordpress",
      "sudo cp -R wordpress/*  /var/www/html/",
      "sudo chown -R apache:apache /var/www/html/",
      

    ]
  }
}  


output "public_ip" {
  value = aws_instance.wordpress.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
  
}

output "db_access_from_ec2" {
  value = "mysql -h ${aws_db_instance.wordpress.address} -P ${aws_db_instance.wordpress.port} -u ${var.username} -p ${var.password}"
}