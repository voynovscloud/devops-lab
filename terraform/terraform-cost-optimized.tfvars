# ============================================================================
# Cost-Optimized Configuration for Demo/Development
# ============================================================================
# This configuration reduces monthly AWS costs from ~$180-240 to ~$50-80
# 
# WARNINGS:
# - Single AZ deployment (no high availability)
# - Minimal resources (may be slow under load)
# - Not suitable for production workloads
#
# Use for:
# - Learning and experimentation
# - Portfolio demonstrations
# - Development environments
# - Proof of concepts
#
# Deploy with: terraform apply -var-file="terraform-cost-optimized.tfvars"
# ============================================================================

# Environment
environment      = "dev"
cost_optimized   = true

# AWS Region (us-east-1 is typically cheapest)
region           = "us-east-1"

# Cluster Configuration
cluster_name     = "devops-lab-dev"

# Networking - Single AZ to save on NAT Gateway costs
availability_zones   = ["us-east-1a"]  # Single AZ only
single_nat_gateway   = true             # One NAT Gateway (~$32/month)

# EKS Node Configuration - Minimal instance
node_instance_type   = "t3.small"       # $0.0208/hr (~$15/month per node)
node_desired_size    = 1                # Start with 1 node
node_min_size        = 1                # Minimum 1 node
node_max_size        = 2                # Allow scaling to 2 nodes max

# RDS Database - Minimal instance
db_instance_class        = "db.t3.micro"    # $0.017/hr (~$12/month)
db_allocated_storage     = 10               # 10 GB (~$1.15/month)
db_max_allocated_storage = 20               # Allow growth to 20 GB
db_multi_az              = false            # Single AZ (no failover)
db_backup_retention_days = 1                # Minimal backups

# Database Credentials (CHANGE THESE!)
db_name     = "appdb"
db_username = "postgres"
# db_password = "SET_VIA_COMMAND_LINE"  # Use: -var="db_password=YourPassword"

# ============================================================================
# ESTIMATED MONTHLY COSTS (us-east-1)
# ============================================================================
# 
# EKS Control Plane:        $75.00  (fixed cost)
# t3.small node x1:         $15.00
# NAT Gateway (single):     $32.00
# NAT Gateway data:         $5.00   (estimated)
# RDS db.t3.micro:          $12.00
# RDS storage (10 GB):      $1.15
# RDS backups (10 GB):      $1.00
# Data transfer:            $2.00   (estimated)
# ----------------------------------------
# TOTAL:                    ~$143.15/month
#
# Additional savings (not in this config):
# - Use Fargate instead of EKS: Save control plane cost
# - Use local PostgreSQL in EKS: Save ~$14/month
# - Spot instances: Save 50-70% on EC2 costs
# - Stop environment when not in use: Save all compute costs
# 
# ============================================================================
# COST COMPARISON
# ============================================================================
#
# Configuration          | Monthly Cost | Use Case
# -----------------------|--------------|-------------------------
# This (Cost-Optimized)  | ~$143/month  | Demo, learning, dev
# Standard (Minimal HA)  | ~$180/month  | Staging, light prod
# Production (Full HA)   | ~$240/month  | Production workloads
# Enterprise (Scaled)    | ~$500+/month | High-traffic production
#
# ============================================================================
