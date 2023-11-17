variable "cluster_name" {
  description = "Name of the Redis cluster group."
  type        = string
  default     = "ewt-redis-cache"
}

variable "apply_immediately" {
  description = "Determines if changes should be applied immediately or during maintenance window."
  type        = bool
  default     = true
}

variable "node_type" {
  description = "Type of instance used for redis nodes.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheNodes.SupportedTypes.html for supported types."
  type        = string
  default     = "cache.m6g.large"
}

variable "num_nodes" {
  description = "Number of nodes in the cluster."
  type        = number
  default     = 2
}

variable "maintenance_window" {
  description = "Maintenance window for changes to redis in 24H UTC.  Format is ddd:hh24:mi-ddd:hh24:mi, e.g. sun:05:00-sun:09:00."
  type        = string
  default     = "sat:07:00-sat:08:00"
}

variable "secret_recovery_window" {
  description = "Time in days AWS Secrets Manager waits before deleting the secret it generates."
  type        = number
  default     = 30
}

variable "vpc_name_common" {
  type        = string
  description = "VPC used to create Security Networks for ElastiCache"
  default     = "vpc-0aab4a52a4f759389"
}
