# ============================================================================
# AWS Region Configuration
# ============================================================================

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
  
  # Popular regions:
  # us-east-1 (N. Virginia) - Cheapest, most services
  # us-west-2 (Oregon) - Good pricing, modern infra
  # eu-central-1 (Frankfurt) - EU data residency
}

# ============================================================================
# Environment Configuration
# ============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cost_optimized" {
  description = "Enable cost optimization for demo/dev environments"
  type        = bool
  default     = false
  
  # When true:
  # - Uses single AZ (no NAT Gateway redundancy)
  # - Smaller EC2 instances (t3.micro/t3.small)
  # - Reduced RDS storage
  # - Cost: ~$50-80/month vs $180-240/month
}

# ============================================================================
# VPC & Networking Configuration
# ============================================================================

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-lab"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  # Cost optimization: Use single AZ
  # default = ["us-east-1a"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (required for EKS)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway across all AZs (cost savings)"
  type        = bool
  default     = false
  
  # true = ~$32/month (one NAT Gateway)
  # false = ~$65/month (NAT Gateway per AZ)
}

# ============================================================================
# EKS Node Group Configuration
# ============================================================================

variable "node_instance_type" {
  description = "EKS worker node EC2 instance type"
  type        = string
  default     = "t3.medium"
  
  # Instance type recommendations:
  # Dev/Demo:  t3.micro   ($0.0104/hr, ~$7.50/month)  - VERY LIMITED
  # Dev:       t3.small   ($0.0208/hr, ~$15/month)    - Minimal workloads
  # Staging:   t3.medium  ($0.0416/hr, ~$30/month)    - Recommended minimum
  # Prod:      t3.large   ($0.0832/hr, ~$60/month)    - Better performance
  # Prod:      t3.xlarge  ($0.1664/hr, ~$120/month)   - High performance
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
  
  # Cost optimization: 1 node
  # Staging: 2 nodes
  # Production: 3+ nodes
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes (auto-scaling)"
  type        = number
  default     = 4
}

# ============================================================================
# RDS PostgreSQL Configuration
# ============================================================================

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password (min 8 characters)"
  type        = string
  sensitive   = true
  
  # SECURITY: Never commit passwords to Git
  # Set via: terraform apply -var="db_password=YourSecurePassword"
  # Or use AWS Secrets Manager
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
  
  # Instance class recommendations:
  # Dev/Demo:  db.t3.micro   ($0.017/hr, ~$12/month)  - 1 vCPU, 1 GB RAM
  # Staging:   db.t3.small   ($0.034/hr, ~$25/month)  - 2 vCPU, 2 GB RAM
  # Prod:      db.t3.medium  ($0.068/hr, ~$50/month)  - 2 vCPU, 4 GB RAM
  # Prod:      db.r5.large   ($0.240/hr, ~$175/month) - 2 vCPU, 16 GB RAM (memory-optimized)
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
  
  # Cost: ~$0.115 per GB/month for gp2
  # Dev: 10 GB (~$1.15/month)
  # Prod: 100 GB (~$11.50/month)
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for auto-scaling (0 = disabled)"
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = false
  
  # true: ~2x cost, automatic failover, 99.95% SLA
  # false: Single AZ, manual recovery, 99.90% SLA
  # Recommended: false for dev, true for production
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
  
  # 0 = disabled (not recommended)
  # 1-7 = dev/staging
  # 30-35 = production
}
