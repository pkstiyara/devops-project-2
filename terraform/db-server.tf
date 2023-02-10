#################################################################################
#                       DB SERVER
#################################################################################
# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

#############################################################

resource "aws_instance" "db-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "sonar"
  subnet_id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.dev-security-group.id]

connection {
    type = "ssh"
    host = self.public_ip
    user = ubuntu
    private_key = file("./sonar.pem")

  }

  tags = {
    Name = "Database Server"
  }
}


##################################################################################
#                           DB EIP 
##################################################################################
resource "aws_eip" "db-server-ngw-id" {
  vpc = true

}