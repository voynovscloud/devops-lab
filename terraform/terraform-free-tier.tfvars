# ============================================================================
# AWS Free Tier Optimized Configuration
# ============================================================================
# Use this for minimal cost deployment (~$0-10/month within Free Tier limits)
# Note: EKS control plane is NOT free ($0.10/hour = ~$75/month)
# ============================================================================

# Region (EU Frankfurt)
region = "eu-central-1"

# Environment
environment = "dev"

# Cluster name (keep it short to avoid IAM role name issues)
cluster_name = "devops-lab"

# VPC Configuration (Free Tier)
vpc_cidr = "10.0.0.0/16"

# Two AZs required by EKS (minimum requirement)
availability_zones = ["eu-central-1a", "eu-central-1b"]

# NAT Gateway (required for EKS but costs ~$32/month)
enable_nat_gateway = true
single_nat_gateway = true  # Use single NAT instead of one per AZ

# EKS Node Configuration (Free Tier eligible)
node_instance_type = "t3.micro"  # Free Tier: 750 hours/month
node_desired_size  = 1           # Minimal nodes
node_min_size      = 1
node_max_size      = 2

# RDS Database Configuration (Free Tier eligible)
db_instance_class = "db.t3.micro"  # Free Tier: 750 hours/month
db_name           = "devopslab"
db_username       = "postgres"
# Set password via environment: export TF_VAR_db_password="YourSecurePassword123!"

# ============================================================================
# Free Tier Limits Summary:
# ============================================================================
# ✅ EC2 t3.micro: 750 hours/month (1 instance 24/7 is ~720 hours)
# ✅ RDS t3.micro: 750 hours/month + 20GB storage
# ✅ S3: 5GB storage
# ✅ VPC: No charge
# ✅ Data Transfer: 1GB/month free outbound
#
# ❌ NOT FREE:
# - EKS Control Plane: $0.10/hour = ~$75/month
# - NAT Gateway: $0.045/hour = ~$32/month + data charges
# - Data transfer over 1GB
#
# TOTAL ESTIMATED COST: ~$75-110/month
# ============================================================================

# ============================================================================
# Cost Optimization Tips:
# ============================================================================
# 1. Delete NAT Gateway when not using (saves $32/month)
# 2. Stop RDS when not in use (saves during downtime)
# 3. Use t3.micro instead of larger instances
# 4. Delete unused EBS volumes
# 5. Set up billing alerts at $10, $50, $100
# 6. Use AWS Cost Explorer to monitor spending
# ============================================================================
