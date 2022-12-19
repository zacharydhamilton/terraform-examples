# --------------------------------------------------------
# Environment
# --------------------------------------------------------
resource "confluent_environment" "simple_env" {
    display_name = "${local.env_name}-${random_id.id.hex}"
    lifecycle {
        prevent_destroy = false
    }
}
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