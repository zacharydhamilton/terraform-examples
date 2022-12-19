# Copy-paste clipboard

`vars.tf`
```hcl
locals {
    env_name = "terraform-dedicated-vpc-peered"
    cluster_name = "dedicated-vpc-peered-cluster"
    description = "Resource created for 'Dedicated VPC Peered Cluster Terraform Pre-work'"
}
```

`providers.tf`
```hcl
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "4.46"
        }
        confluent = {
            source = "confluentinc/confluent"
            version = "1.23.0"
        }
    }
}
```

`aws.tf`
```hcl
# --------------------------------------------------------
# This 'random_id' will make whatever you create (names, etc)
# unique in your account.
# --------------------------------------------------------
resource "random_id" "id" {
    byte_length = 4
}
```

```hcl
# --------------------------------------------------------
# VPC
# --------------------------------------------------------
resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "simple-vpc-${random_id.id.hex}"
  }
}
```

```hcl
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
```

```hcl
# --------------------------------------------------------
# IGW
# --------------------------------------------------------
resource "aws_internet_gateway" "simple_igw" {
    vpc_id = aws_vpc.simple_vpc.id 

    tags = {
        Name = "simple-igw-${random_id.id.hex}"
    }
}
```

```hcl
# --------------------------------------------------------
# Route Table
# --------------------------------------------------------
resource "aws_route_table" "simple_route_table" {
    vpc_id = aws_vpc.simple_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.simple_igw.id
    }

    route {
        cidr_block = confluent_network.simple_network.cidr
        vpc_peering_connection_id = data.aws_vpc_peering_connection.simple_peering_connection.id 
    }

    tags = {
        Name = "simple-route-table-${random_id.id.hex}"
    }
}
```

```hcl 
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
```

`confluent.tf`
```hcl
# --------------------------------------------------------
# Environment
# --------------------------------------------------------
resource "confluent_environment" "simple_env" {
    display_name = "${local.env_name}-${random_id.id.hex}"
    lifecycle {
        prevent_destroy = false
    }
}
```

```hcl
# --------------------------------------------------------
# Network
# --------------------------------------------------------
resource "confluent_network" "simple_network" {
    display_name = "${substr(local.env_name,0,31)}-${random_id.id.hex}"
    cloud = "AWS"
    region = "us-east-2"
    cidr = "10.1.0.0/16"
    connection_types = ["PEERING"]
    environment {
        id = confluent_environment.simple_env.id
    }
    lifecycle {
        prevent_destroy = false
    }
}
```

```hcl
# --------------------------------------------------------
# Peering
# --------------------------------------------------------
resource "confluent_peering" "simple_peering" {
    display_name = "peering-${random_id.id.hex}"
    aws {
        account = data.aws_caller_identity.simple_account.account_id
        vpc = aws_vpc.simple_vpc.id
        routes = ["10.0.0.0/16"]
        customer_region = "us-east-2"
    }
    environment {
        id = confluent_environment.simple_env.id
    }
    network {
        id = confluent_network.simple_network.id 
    }
    lifecycle {
        prevent_destroy = false
    }
}
```