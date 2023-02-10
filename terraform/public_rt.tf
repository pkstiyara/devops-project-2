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


