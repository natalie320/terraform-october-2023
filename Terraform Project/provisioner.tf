resource "null_resource" "cluster" {
    triggers = {
        always_run = "${timestamp()}"
    }

    connection {
      host = element(aws_instance.web[*].public_ip,0)
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
    }

    provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install -y lamp-mariadb 10.2-php7.2 php7.2", 
        "sudo yum install mariadb-server -y", 
        "sudo yum install httpd -y", 
        "sudo systemctl start httpd", 
        "sudo systemctl enable httpd",
        "wget https://wordpress.org/latest.tar.gz",
        "tar xvf latest.tar.gz",
        "sudo chown -R apache:apache /var/www/html/", 
        "sudo cp -R wordpress/* /var/www/html/"
    ]
}
}

