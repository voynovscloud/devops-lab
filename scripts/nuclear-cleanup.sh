#!/bin/bash
# Nuclear cleanup - removes ALL devops-lab resources from AWS

set -e
CLUSTER="devops-lab"
REGION="us-east-1"

echo "☢️  NUCLEAR CLEANUP - Removing all $CLUSTER resources..."

# 1. Delete RDS instances
echo "1️⃣ Deleting RDS instances..."
RDS_INSTANCES=$(aws rds describe-db-instances --query "DBInstances[?contains(DBInstanceIdentifier, '$CLUSTER')].DBInstanceIdentifier" --output text 2>/dev/null || true)
for RDS in $RDS_INSTANCES; do
    echo "   Deleting RDS: $RDS"
    aws rds delete-db-instance --db-instance-identifier $RDS --skip-final-snapshot 2>/dev/null || true
done

# 2. Delete EKS cluster
echo "2️⃣ Deleting EKS cluster..."
aws eks delete-cluster --name $CLUSTER --region $REGION 2>/dev/null || true

# 3. Delete KMS aliases
echo "3️⃣ Deleting KMS aliases..."
KMS_ALIAS="alias/eks/$CLUSTER"
aws kms delete-alias --alias-name $KMS_ALIAS 2>/dev/null || true

# 4. Delete CloudWatch Log Groups
echo "4️⃣ Deleting CloudWatch Log Groups..."
LOG_GROUPS=$(aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$CLUSTER" --query 'logGroups[*].logGroupName' --output text 2>/dev/null || true)
for LOG_GROUP in $LOG_GROUPS; do
    echo "   Deleting log group: $LOG_GROUP"
    aws logs delete-log-group --log-group-name "$LOG_GROUP" 2>/dev/null || true
done

# 5. Delete IAM roles
echo "5️⃣ Deleting IAM roles..."
IAM_ROLE="eks-general-node-role"
# Detach policies first
ATTACHED=$(aws iam list-attached-role-policies --role-name $IAM_ROLE --query 'AttachedPolicies[*].PolicyArn' --output text 2>/dev/null || true)
for POLICY in $ATTACHED; do
    echo "   Detaching policy: $POLICY"
    aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn $POLICY 2>/dev/null || true
done
# Delete inline policies
INLINE=$(aws iam list-role-policies --role-name $IAM_ROLE --query 'PolicyNames[*]' --output text 2>/dev/null || true)
for POLICY in $INLINE; do
    echo "   Deleting inline policy: $POLICY"
    aws iam delete-role-policy --role-name $IAM_ROLE --policy-name $POLICY 2>/dev/null || true
done
# Delete role
aws iam delete-role --role-name $IAM_ROLE 2>/dev/null || true

# 6. Delete VPCs
echo "6️⃣ Deleting VPCs..."
VPC_IDS=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$CLUSTER-vpc" --query 'Vpcs[*].VpcId' --output text 2>/dev/null || true)
for VPC_ID in $VPC_IDS; do
    echo "   Processing VPC: $VPC_ID"
    
    # Delete NAT Gateways
    NAT_IDS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" --query 'NatGateways[*].NatGatewayId' --output text 2>/dev/null || true)
    for NAT_ID in $NAT_IDS; do
        echo "     Deleting NAT: $NAT_ID"
        aws ec2 delete-nat-gateway --nat-gateway-id $NAT_ID 2>/dev/null || true
    done
    
    # Wait for NAT deletion
    if [ ! -z "$NAT_IDS" ]; then
        echo "     Waiting 90s for NAT deletion..."
        sleep 90
    fi
    
    # Delete subnets
    SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text 2>/dev/null || true)
    for SUBNET_ID in $SUBNET_IDS; do
        echo "     Deleting subnet: $SUBNET_ID"
        aws ec2 delete-subnet --subnet-id $SUBNET_ID 2>/dev/null || true
    done
    
    # Detach and delete Internet Gateways
    IGW_IDS=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[*].InternetGatewayId' --output text 2>/dev/null || true)
    for IGW_ID in $IGW_IDS; do
        echo "     Detaching/deleting IGW: $IGW_ID"
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID 2>/dev/null || true
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID 2>/dev/null || true
    done
    
    # Delete route tables
    RT_IDS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' --output text 2>/dev/null || true)
    for RT_ID in $RT_IDS; do
        echo "     Deleting route table: $RT_ID"
        aws ec2 delete-route-table --route-table-id $RT_ID 2>/dev/null || true
    done
    
    # Delete security groups
    SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text 2>/dev/null || true)
    for SG_ID in $SG_IDS; do
        echo "     Deleting security group: $SG_ID"
        aws ec2 delete-security-group --group-id $SG_ID 2>/dev/null || true
    done
    
    # Delete VPC
    echo "     Deleting VPC: $VPC_ID"
    aws ec2 delete-vpc --vpc-id $VPC_ID 2>/dev/null || true
done

# 7. Release Elastic IPs
echo "7️⃣ Releasing Elastic IPs..."
EIP_ALLOCS=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=*$CLUSTER*" --query 'Addresses[*].AllocationId' --output text 2>/dev/null || true)
for ALLOC_ID in $EIP_ALLOCS; do
    echo "   Releasing EIP: $ALLOC_ID"
    aws ec2 release-address --allocation-id $ALLOC_ID 2>/dev/null || true
done

echo ""
echo "✅ Nuclear cleanup complete!"
echo "⏳ Wait 2-3 minutes for AWS to finish deleting resources"
echo ""
echo "Then run:"
echo "  cd terraform/"
echo "  rm -f terraform.tfstate* .terraform.lock.hcl"
echo "  terraform init"
echo "  terraform apply -var-file='terraform-free-tier.tfvars'"
