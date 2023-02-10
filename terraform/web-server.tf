#################################################################################
#                       WEB SERVER
#################################################################################



resource "aws_instance" "web-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "sonar"
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.dev-security-group.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = ubuntu
    private_key = file("./sonar.pem")

  }

  tags = {
    Name = "Web Server"
  }
}


################################################################
#              WEB SERVER ELASTIC IP
################################################################

resource "aws_eip" "web-eip" {
  instance = aws_instance.web-server.id
  vpc      = true

}

###############################################################
