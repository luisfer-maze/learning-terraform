locals {
  vpn_user_cidr = "10.21.0.0/16"
}

resource "aws_subnet" "core_subnet" {
  vpc_id     = aws_vpc.target_vpc.id
  cidr_block = "172.31.0.0/24"
}

resource "aws_elasticache_subnet_group" "ewt_redis" {
  name       = var.cluster_name
  subnet_ids = [aws_subnet.core_subnet.id]
}

resource "aws_vpc" "target_vpc" {
    cidr_block = "172.31.0.0/16"
}

resource "aws_security_group" "ewt_elasticache_sg" {
  name        = "${var.cluster_name}_access"
  description = "Provides access to cluster: ${var.cluster_name} from shared EKS."
  vpc_id      = aws_vpc.target_vpc.id

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
    cidr_blocks = [aws_vpc.target_vpc.cidr_block]
  }
}
