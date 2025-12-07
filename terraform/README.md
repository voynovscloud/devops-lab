# Terraform AWS Deployment

This directory contains Terraform configurations for deploying the DevOps Lab infrastructure on AWS.

## Infrastructure Components

### VPC Module
- **1 VPC** with CIDR `10.0.0.0/16`
- **2 Public Subnets** (`10.0.101.0/24`, `10.0.102.0/24`) in different AZs
- **2 Private Subnets** (`10.0.1.0/24`, `10.0.2.0/24`) in different AZs
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for private subnet outbound connectivity
- **Route Tables** configured for public and private subnets

### EKS Cluster
- **Cluster Name**: `devops-lab`
- **Kubernetes Version**: 1.28
- **Node Groups**: 
  - General purpose: 2x `t3.medium` instances
  - Spot instances: 2x `t3.medium` instances with cost optimization
- **IAM Roles for Service Accounts (IRSA)** enabled
- **Public API endpoint** enabled
- **EBS CSI Driver** IAM policy attached

### RDS PostgreSQL
- **Engine**: PostgreSQL 15.4
- **Instance Class**: `db.t3.micro`
- **Storage**: 20GB (auto-scaling up to 100GB)
- **Multi-AZ**: Disabled (single instance)
- **Backup Retention**: 7 days
- **Security**: Accessible only from EKS cluster security group
- **Public Access**: Disabled

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- kubectl
- helm

## Deployment Steps

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review Variables

Edit `terraform.tfvars` or set environment variables:

```bash
export TF_VAR_db_password="YourSecurePassword123!"
```

### 3. Plan Infrastructure

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

This will create:
- VPC with networking components (~2 minutes)
- EKS cluster (~15 minutes)
- RDS PostgreSQL instance (~10 minutes)

**Total deployment time: ~30 minutes**

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --region eu-central-1 --name devops-lab
```

Or use the output command:

```bash
terraform output -raw configure_kubectl | bash
```

### 6. Verify Cluster Access

```bash
kubectl get nodes
kubectl get namespaces
```

### 7. Deploy Application

```bash
cd ..

# Update Helm values with RDS endpoint
export RDS_ENDPOINT=$(cd terraform && terraform output -raw rds_endpoint)
export DB_NAME=$(cd terraform && terraform output -raw rds_database_name)

# Deploy via Helm
helm install devops-lab ./devops-lab-chart \
  --set database.enabled=true \
  --set database.host="${RDS_ENDPOINT%%:*}" \
  --set database.name="${DB_NAME}" \
  --set database.user="dbadmin" \
  --set database.password="${TF_VAR_db_password}"
```

## Outputs

After deployment, Terraform provides:

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC identifier |
| `public_subnets` | Public subnet IDs |
| `private_subnets` | Private subnet IDs |
| `eks_cluster_name` | EKS cluster name |
| `eks_cluster_endpoint` | Kubernetes API endpoint |
| `rds_endpoint` | Database endpoint (host:port) |
| `rds_database_name` | Database name |
| `configure_kubectl` | Command to configure kubectl |

View outputs:

```bash
terraform output
```

## Cost Estimation

Monthly costs (eu-central-1):

| Resource | Type | Quantity | Est. Cost |
|----------|------|----------|-----------|
| EKS Cluster | Control Plane | 1 | $72 |
| EC2 Instances | t3.medium | 2-4 | $60-120 |
| NAT Gateway | Single | 1 | $32 |
| RDS | db.t3.micro | 1 | $15 |
| EBS Volumes | gp3 | ~40GB | $5 |
| **Total** | | | **~$184-244/month** |

**Note**: Costs may vary based on usage, data transfer, and AWS pricing changes.

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**Warning**: This will permanently delete all resources including databases. Ensure you have backups if needed.

## Security Considerations

1. **Database Credentials**: Store in AWS Secrets Manager or use Terraform Cloud for sensitive variables
2. **Network Isolation**: RDS is only accessible from EKS cluster
3. **Node Security**: Nodes are in private subnets
4. **IAM Roles**: Least privilege principle applied
5. **Encryption**: Enable RDS encryption for production

## Troubleshooting

### Issue: kubectl connection timeout

```bash
# Check cluster status
aws eks describe-cluster --name devops-lab --region eu-central-1

# Update kubeconfig
aws eks update-kubeconfig --region eu-central-1 --name devops-lab
```

### Issue: Nodes not joining cluster

```bash
# Check node group status
aws eks describe-nodegroup --cluster-name devops-lab --nodegroup-name devops-lab-node-group-1

# View node group logs
kubectl get nodes
kubectl describe node <node-name>
```

### Issue: Database connection failed

```bash
# Test database connectivity from a pod
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h <RDS_ENDPOINT> -U dbadmin -d devopslab
```

## Next Steps

1. **Setup Load Balancer**: Deploy AWS Load Balancer Controller
2. **Configure DNS**: Route53 for domain management
3. **SSL Certificates**: cert-manager with Let's Encrypt
4. **Monitoring**: Deploy Prometheus/Grafana to EKS
5. **ArgoCD**: Deploy for GitOps on AWS EKS
6. **Secrets Management**: Integrate AWS Secrets Manager
7. **Backup**: Configure Velero for cluster backups
