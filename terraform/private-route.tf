
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
resource "aws_route_table_association" "private-rt-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route.id
}

#################################################################################