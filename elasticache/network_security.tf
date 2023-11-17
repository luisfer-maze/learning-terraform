locals {
  subnet_cloudformation_export_names = toset(["CoreNetwork-Az1CoreSubnet", "CoreNetwork-Az2CoreSubnet"])
  vpn_user_cidr                      = "10.21.0.0/16"
}

data "aws_cloudformation_export" "subnet_id" {
  for_each = local.subnet_cloudformation_export_names
  name     = each.value
}

data "aws_subnet" "core_subnet" {
  for_each = data.aws_cloudformation_export.subnet_id
  id       = each.value.value
}

resource "aws_elasticache_subnet_group" "ewt_redis" {
  name       = var.cluster_name
  subnet_ids = [for subnet in data.aws_subnet.core_subnet : subnet.id]
}

data "aws_vpc" "target_vpc" {
  id = var.vpc_name_common
}

resource "aws_security_group" "ewt_elasticache_sg" {
  name        = "${var.cluster_name}_access"
  description = "Provides access to cluster: ${var.cluster_name} from shared EKS."
  vpc_id      = data.aws_vpc.target_vpc.id

  ingress {
    description = "Redis connection from VPN users."
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [local.vpn_user_cidr]
  }

  ingress {
    description = "Redis connection from Core Network to ElastiCache."
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.target_vpc.cidr_block]
  }
}
