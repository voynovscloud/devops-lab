#!/bin/bash
# Terraform Pre-Flight Check for eu-central-1
# Verifies configuration before terraform apply

set -e
REGION="eu-central-1"
CLUSTER_NAME="devops-lab"

echo "🔍 Terraform Pre-Flight Check"
echo "================================"
echo ""

# 1. Check AWS credentials
echo "✓ Checking AWS credentials..."
aws sts get-caller-identity --region $REGION > /dev/null 2>&1 || {
    echo "❌ AWS credentials not configured!"
    echo "Run: aws configure"
    exit 1
}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "  AWS Account: $ACCOUNT_ID"
echo "  Region: $REGION"
echo ""

# 2. Check if DB password is set
echo "✓ Checking TF_VAR_db_password..."
if [ -z "$TF_VAR_db_password" ]; then
    echo "❌ TF_VAR_db_password not set!"
    echo "Run: export TF_VAR_db_password='YourSecurePassword123!'"
    exit 1
fi
echo "  DB password is set ✓"
echo ""

# 3. Check existing EKS cluster
echo "✓ Checking for existing EKS cluster..."
if aws eks describe-cluster --name $CLUSTER_NAME --region $REGION > /dev/null 2>&1; then
    echo "  ⚠️  EKS cluster '$CLUSTER_NAME' already exists!"
    STATUS=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.status' --output text)
    echo "  Status: $STATUS"
else
    echo "  No existing cluster ✓"
fi
echo ""

# 4. Check existing RDS
echo "✓ Checking for existing RDS..."
if aws rds describe-db-instances --db-instance-identifier ${CLUSTER_NAME}-postgres --region $REGION > /dev/null 2>&1; then
    echo "  ⚠️  RDS instance '${CLUSTER_NAME}-postgres' already exists!"
    STATUS=$(aws rds describe-db-instances --db-instance-identifier ${CLUSTER_NAME}-postgres --region $REGION --query 'DBInstances[0].DBInstanceStatus' --output text)
    echo "  Status: $STATUS"
else
    echo "  No existing RDS ✓"
fi
echo ""

# 5. Check VPC limits
echo "✓ Checking VPC limits..."
VPC_COUNT=$(aws ec2 describe-vpcs --region $REGION --query 'length(Vpcs)' --output text)
echo "  Current VPCs: $VPC_COUNT/5 (AWS default limit)"
if [ $VPC_COUNT -ge 5 ]; then
    echo "  ⚠️  VPC limit reached! Delete unused VPCs first."
fi
echo ""

# 6. Terraform validation
echo "✓ Validating Terraform configuration..."
cd /home/voynovs/devops-lab/terraform
terraform init > /dev/null 2>&1
terraform validate > /dev/null 2>&1 || {
    echo "❌ Terraform validation failed!"
    terraform validate
    exit 1
}
echo "  Terraform config valid ✓"
echo ""

# 7. Show what will be created
echo "✓ Terraform Plan Summary:"
terraform plan -var-file="terraform-free-tier.tfvars" -compact-warnings 2>&1 | grep -E "Plan:|will be created|will be updated|will be destroyed" | head -20
echo ""

# 8. Cost estimate
echo "💰 COST ESTIMATE:"
echo "================================"
echo "Monthly costs (eu-central-1):"
echo "  EKS Control Plane:    ~€70-75/month  (NOT Free Tier)"
echo "  NAT Gateway:          ~€30/month     (NOT Free Tier)"
echo "  EC2 t3.micro (1x):    €0            (Free Tier 750h)"
echo "  RDS db.t3.micro:      €0            (Free Tier 750h)"
echo "  Data Transfer:        ~€5/month"
echo "  --------------------------------"
echo "  TOTAL:                ~€105-110/month"
echo ""
echo "⚠️  Deploy for 2-3 days only (~€7-10 total)!"
echo ""

# 9. Final check
echo "================================"
echo "✅ Pre-flight check complete!"
echo ""
echo "Ready to deploy? Run:"
echo "  cd terraform/"
echo "  terraform apply -var-file='terraform-free-tier.tfvars'"
echo ""
echo "After demo (IMPORTANT to avoid charges):"
echo "  terraform destroy -var-file='terraform-free-tier.tfvars'"
