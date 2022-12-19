# --------------------------------------------------------
# This 'random_id' will make whatever you create (names, etc)
# unique in your account.
# --------------------------------------------------------
resource "random_id" "id" {
    byte_length = 4
}
# --------------------------------------------------------
# VPC
# --------------------------------------------------------
resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "simple-vpc-${random_id.id.hex}"
  }
}
# --------------------------------------------------------
# Subnets
# --------------------------------------------------------
resource "aws_subnet" "simple_subnets" {
    count = 3
    vpc_id = aws_vpc.simple_vpc.id
    cidr_block = "10.0.${count.index+1}.0/24"

    tags = {
        Name = "simple-subnet-${count.index}-${random_id.id.hex}"
    }
}
# --------------------------------------------------------
# IGW
# --------------------------------------------------------
resource "aws_internet_gateway" "simple_igw" {
    vpc_id = aws_vpc.simple_vpc.id 

    tags = {
        Name = "simple-igw-${random_id.id.hex}"
    }
}
# --------------------------------------------------------
# Route Table
# --------------------------------------------------------
resource "aws_route_table" "simple_route_table" {
    vpc_id = aws_vpc.simple_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.simple_igw.id
    }

    tags = {
        Name = "simple-route-table-${random_id.id.hex}"
    }
}
# --------------------------------------------------------
# Peering
# --------------------------------------------------------
data "aws_caller_identity" "simple_account" {
    provider = aws
}
data "aws_vpc_peering_connection" "simple_peering_connection" {
    vpc_id = confluent_network.simple_network.aws[0].vpc
    peer_vpc_id = confluent_peering.simple_peering.aws[0].vpc
}
resource "aws_vpc_peering_connection_accepter" "simple_peering_connection_accepter" {
    vpc_peering_connection_id = data.aws_vpc_peering_connection.simple_peering_connection.id
    auto_accept = true
}


