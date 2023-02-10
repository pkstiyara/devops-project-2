resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"


    tags = {
      "Name" = "dev-vpc"
    }
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
      "Name" = "Public-Subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.2.0/24"

    tags = {
      "Name" = "Private-Subnet"
    }
}


resource "aws_security_group" "dev-security-group" {
  name        = "dev-security-group"
  description = "Dev- Security Group"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description      = "Open For HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Open for Port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "Open for HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "Open for Everywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev Security Group"
  }
}

############################################################
#                   AWS INTERNET GATEWAY            
############################################################

resource "aws_internet_gateway" "dev-igw" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
      "Name" = "Dev Internet Gateway"
    }
}

###########################################################
#               PUBLIC ROUTE TABLE
##########################################################

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }


  tags = {
    Name = "Public RT"
  }
}

########################### Public Route Table Association ##########################

resource "aws_main_route_table_association" "public-route-asso" {
  vpc_id         = aws_vpc.dev-vpc.id
  route_table_id = aws_route_table.public-route.id
}





#################################################################################
#                       WEB SERVER
#################################################################################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#############################################################

resource "aws_instance" "web-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "sonar"
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.dev-security-group.id]

connection {
    type = "ssh"
    host = self.public_ip
    user = ubuntu
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
    vpc = true
  
}

###############################################################


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


resource "aws_eip" "db-server-ngw-id" {
    vpc = true
    
}

##################################################################
#                   NAT GATEWAY
##################################################################

resource "aws_nat_gateway" "dev-ngw" {
    subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT Gateway"
  }
}

  ####################################################################################
 #                       PRIVATE ROUTE TABLE
####################################################################################


resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev-ngw.id
  }


  tags = {
    Name = "Private RT"
  }
}

######################### Private Route Table Association #########################
resource "aws_route_table_association" "private-rt-asso"{
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.private-route.id
}

#################################################################################