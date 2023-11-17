# Creates/manages KMS CMK
resource "aws_kms_key" "elasticache_cmk_key" {
  description              = "Key used to encrypt Elasticache data"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = true
}

# Add an alias to the key
resource "aws_kms_alias" "by_alias" {
  name          = "alias/dfw-ewt-key-elasticache"
  target_key_id = aws_kms_key.elasticache_cmk_key.key_id
}

resource "aws_elasticache_replication_group" "ewt_elasticache" {
  replication_group_id = var.cluster_name
  description          = "Elasticache redis cluster group for the EWT action."

  apply_immediately          = var.apply_immediately
  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.elasticache_cmk_key.arn
  automatic_failover_enabled = true
  engine                     = "redis"
  engine_version             = "7.x"
  auto_minor_version_upgrade = true
  node_type                  = var.node_type
  num_cache_clusters         = var.num_nodes
  maintenance_window         = var.maintenance_window
  multi_az_enabled           = true
  port                       = 6379
  transit_encryption_enabled = true
  user_group_ids             = [aws_elasticache_user_group.redis_user_group.id]
  subnet_group_name          = aws_elasticache_subnet_group.ewt_redis.name
  security_group_ids         = [aws_security_group.ewt_elasticache_sg.id]

  # Commented until we define if we need to export slow and/or engine logs

  # log_delivery_configuration {
  #   destination      = aws_cloudwatch_log_group.ewt_slowlog_group.name
  #   destination_type = "cloudwatch-logs"
  #   log_format       = "json"
  #   log_type         = "slow-log"
  # }

  # log_delivery_configuration {
  #   destination      = aws_cloudwatch_log_group.ewt_enginelog_group.name
  #   destination_type = "cloudwatch-logs"
  #   log_format       = "json"
  #   log_type         = "engine-log"
  # }
}

resource "aws_elasticache_user" "redis_user" {
  user_id       = var.cluster_name
  user_name     = "default"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords = [
    jsondecode(data.aws_secretsmanager_secret_version.lookup_password.secret_string).first_password,
    jsondecode(data.aws_secretsmanager_secret_version.lookup_password.secret_string).second_password
  ]
}

resource "aws_elasticache_user_group" "redis_user_group" {
  user_group_id = var.cluster_name
  engine        = "REDIS"
  user_ids      = [aws_elasticache_user.redis_user.user_id]

  lifecycle {
    ignore_changes = [user_ids]
  }
}

# Commented until we define if we need to export slow and/or engine logs

# resource "aws_cloudwatch_log_group" "ewt_slowlog_group" {
#   name              = "${var.cluster_name}-slowlog"
#   retention_in_days = 7
#   kms_key_id        = aws_kms_key.elasticache_cmk_key.arn
# }

# resource "aws_cloudwatch_log_group" "ewt_enginelog_group" {
#   name              = "${var.cluster_name}-enginelog"
#   retention_in_days = 7
#   kms_key_id        = aws_kms_key.elasticache_cmk_key.arn
# }
