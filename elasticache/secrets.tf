data "aws_secretsmanager_random_password" "redis_passwords" {
  count = 2

  password_length            = 30
  require_each_included_type = true
  exclude_punctuation        = true
}

resource "aws_secretsmanager_secret" "ewt_secrets" {
  name                    = "ewt/${var.cluster_name}/redis"
  description             = "Elasticache Redis password fo the ${var.cluster_name} deployment."
  recovery_window_in_days = var.secret_recovery_window
  kms_key_id              = aws_kms_key.elasticache_cmk_key.arn
}

resource "aws_secretsmanager_secret_version" "ewt_passwords" {
  secret_id = aws_secretsmanager_secret.ewt_secrets.id
  secret_string = jsonencode({
    first_password   = data.aws_secretsmanager_random_password.redis_passwords[0].random_password
    second_password  = data.aws_secretsmanager_random_password.redis_passwords[1].random_password
    current_password = "first_password"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_secretsmanager_secret_version" "lookup_password" {
  depends_on = [aws_secretsmanager_secret_version.ewt_passwords]
  secret_id  = aws_secretsmanager_secret.ewt_secrets.id
}
