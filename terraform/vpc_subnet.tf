
############################################################
#                   AWS VPC           
############################################################

resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"


  tags = {
    "Name" = "dev-vpc"
  }
}


############################################################
#                   PUBLIC SUBNET            
############################################################

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    "Name" = "Public-Subnet"
  }
}



############################################################
#                   PRIVATE SUBNET            
############################################################
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    "Name" = "Private-Subnet"
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


##################################################################
#                   NAT GATEWAY
##################################################################

resource "aws_nat_gateway" "dev-ngw" {
  allocation_id = aws_eip.db-server-ngw-id.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT Gateway"
  }
}