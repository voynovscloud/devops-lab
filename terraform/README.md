# ☁️ Terraform - AWS Infrastructure as Code

## 📋 What Is Terraform?

Terraform is a tool that lets you define your entire cloud infrastructure (servers, networks, databases) in code files. Instead of clicking through the AWS console and manually creating resources, you:

1. **Write** infrastructure as code (`.tf` files)
2. **Review** what will be created (`terraform plan`)
3. **Apply** changes automatically (`terraform apply`)

**Why is this powerful?**
- ✅ **Version Control**: Your infrastructure is in Git, with full history
- ✅ **Reproducible**: Destroy and recreate identical environments anytime
- ✅ **Consistent**: No manual mistakes or forgotten steps
- ✅ **Automated**: No clicking through AWS console

---

## 🏗️ What This Creates on AWS

This Terraform code will automatically build:

### 1. **Network (VPC)**
- 1 Virtual Private Cloud (10.0.0.0/16 - like your own private data center)
- 2 Public Subnets (for resources that need internet access)
- 2 Private Subnets (for databases and internal resources)
- Internet Gateway (connects to the internet)
- NAT Gateway (lets private resources reach the internet)

**Think of it as:** Building a private network in the cloud with public and private sections.

### 2. **Kubernetes Cluster (EKS)**
- Managed Kubernetes cluster (version 1.28)
- 4 worker nodes (2 regular + 2 spot instances for cost savings)
- Each node: t3.medium (2 CPUs, 4GB RAM)
- Auto-configured networking and security

**Think of it as:** A production-ready Kubernetes cluster that AWS manages for you.

### 3. **Database (RDS PostgreSQL)**
- PostgreSQL 15.4 database
- db.t3.micro instance (1 CPU, 1GB RAM)
- 20GB storage (auto-scales to 100GB if needed)
- 7-day automated backups
- Only accessible from your EKS cluster (secure)

**Think of it as:** A managed PostgreSQL database that automatically handles backups and security.

---

## 💰 Cost Breakdown

**Monthly Cost: ~$180-240**

| Resource | Cost/Month | What It Is |
|----------|------------|------------|
| **EKS Cluster** | $73 | Managed Kubernetes control plane |
| **EC2 Nodes (4x t3.medium)** | $120 | Worker servers running your apps |
| **RDS Database** | $16 | PostgreSQL database |
| **NAT Gateway** | $33 | Allows private resources to reach internet |
| **Storage & Data Transfer** | $10-20 | EBS volumes and network traffic |

⚠️ **Important**: Remember to run `terraform destroy` when done to avoid charges!

---

## 📋 Prerequisites

Before you start, you need:

1. **AWS Account** with billing enabled
2. **AWS CLI** installed and configured:
   ```bash
   aws configure
   # Enter your AWS Access Key, Secret Key, and region
   ```
3. **Terraform** installed:
   ```bash
   # Mac
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```
4. **kubectl** installed (for managing Kubernetes)

---

## 🚀 Deployment Steps (30 minutes total)

### Step 1: Initialize Terraform

```bash
cd terraform

# Download required provider plugins (AWS, Kubernetes)
terraform init
```

### Step 2: Set Database Password

```bash
# Set secure password for PostgreSQL
export TF_VAR_db_password="YourSecurePassword123!"

# Optional: Create terraform.tfvars file
echo 'db_password = "YourSecurePassword123!"' > terraform.tfvars
```

### Step 3: Preview Changes

```bash
# See what will be created (doesn't actually create anything)
terraform plan
```

This shows you:
- What resources will be created
- Estimated costs
- Any errors before deployment

### Step 4: Deploy to AWS

```bash
# Create all infrastructure (takes ~30 minutes)
terraform apply

# Type 'yes' when prompted
```

**What happens:**
- ⏱️ Minutes 0-5: VPC, subnets, internet gateway created
- ⏱️ Minutes 5-20: EKS cluster created
- ⏱️ Minutes 20-30: RDS database created
- ✅ Done!

### Step 5: Configure kubectl

```bash
# Connect kubectl to your new EKS cluster
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# Or use the output command
terraform output -raw configure_kubectl | bash
```

### Step 6: Verify Everything Works

```bash
# Check nodes are ready
kubectl get nodes

# Should see 4 nodes (2 general + 2 spot)
```

### Step 7: Deploy Your Application

```bash
# Go back to main directory
cd ..

# Get database connection info
export RDS_ENDPOINT=$(cd terraform && terraform output -raw rds_endpoint)
export DB_NAME=$(cd terraform && terraform output -raw rds_database_name)

# Deploy app with Helm
helm install devops-lab ./devops-lab-chart \
  --set database.enabled=true \
  --set database.host="${RDS_ENDPOINT%%:*}" \
  --set database.name="${DB_NAME}" \
  --set database.user="dbadmin" \
  --set database.password="${TF_VAR_db_password}"
```

---

## 📊 Terraform Outputs

After deployment, you can view connection info:

```bash
# View all outputs
terraform output

# View specific output
terraform output rds_endpoint
terraform output eks_cluster_endpoint
```

| Output | What It Is |
|--------|------------|
| `vpc_id` | Your VPC identifier |
| `eks_cluster_name` | Kubernetes cluster name |
| `eks_cluster_endpoint` | Kubernetes API URL |
| `rds_endpoint` | Database connection string |
| `rds_database_name` | Database name |

---

## 🧹 Cleanup (Destroy Everything)

**⚠️ WARNING**: This deletes ALL resources permanently!

```bash
cd terraform

# Destroy all infrastructure
terraform destroy

# Type 'yes' when prompted
```

**Takes ~15 minutes to delete everything.**

Make sure to destroy resources when done to avoid AWS charges!

---

## 🚨 Troubleshooting

### Can't Connect to Cluster

```bash
# Check cluster exists
aws eks describe-cluster --name devops-lab --region eu-central-1

# Reconfigure kubectl
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# Test connection
kubectl get nodes
```

### Nodes Won't Join Cluster

```bash
# Check node status
kubectl get nodes

# Describe node for errors
kubectl describe node <node-name>

# Check AWS node group status
aws eks describe-nodegroup \
  --cluster-name devops-lab \
  --nodegroup-name devops-lab-node-group-general
```

### Can't Connect to Database

```bash
# Get database endpoint
terraform output rds_endpoint

# Test from within cluster
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h <RDS_ENDPOINT> -U dbadmin -d devopslab

# Check security group allows EKS access
```

### Terraform Errors

```bash
# Re-initialize if providers changed
terraform init -upgrade

# Refresh state if resources were manually changed
terraform refresh

# View detailed error logs
terraform apply -auto-approve 2>&1 | tee terraform.log
```

---

## 🔒 Security Best Practices

| Security Feature | Implementation | Why It Matters |
|------------------|----------------|----------------|
| **Database Isolation** | RDS in private subnets only | Not accessible from internet |
| **Network Segmentation** | Public/private subnet separation | Apps in private, load balancers in public |
| **Encrypted Credentials** | Use AWS Secrets Manager | Don't store passwords in code |
| **IAM Roles** | Least privilege access | Each resource only gets needed permissions |
| **Security Groups** | Restrict traffic | Only allow necessary connections |

**For production:**
- Enable RDS encryption at rest
- Use AWS Secrets Manager for passwords
- Enable VPC Flow Logs for network monitoring
- Set up AWS GuardDuty for threat detection

---

## 📁 File Structure

```
terraform/
├── main.tf           # Main configuration (calls modules)
├── vpc.tf            # Network setup (VPC, subnets, gateways)
├── eks.tf            # Kubernetes cluster configuration
├── rds.tf            # PostgreSQL database setup
├── variables.tf      # Input variables
├── outputs.tf        # Output values after deployment
├── provider.tf       # AWS provider configuration
└── terraform.tfvars.example  # Example values file
```

---

## 🎓 Interview Tips

**Q: What is Infrastructure as Code (IaC)?**  
A: IaC is managing infrastructure using code files instead of manual configuration. Benefits include version control, reproducibility, automation, and consistency across environments.

**Q: Why use Terraform instead of AWS console?**  
A: 
- **Version Control**: Infrastructure changes are tracked in Git
- **Reproducible**: Can recreate identical environments
- **Automated**: No manual clicking
- **Consistent**: No human errors or forgotten steps
- **Multi-cloud**: Same tool works for AWS, Azure, GCP

**Q: What's the difference between `terraform plan` and `terraform apply`?**  
A: `terraform plan` shows what *will* change (preview only). `terraform apply` actually creates/modifies/destroys resources. Always run plan first!

**Q: How do you handle secrets in Terraform?**  
A: Use environment variables (`TF_VAR_*`), AWS Secrets Manager, or HashiCorp Vault. Never commit passwords to Git!

**Q: What is Terraform state?**  
A: A file (`terraform.tfstate`) that tracks what infrastructure Terraform created. It maps your code to real-world resources. For teams, store it remotely (S3 + DynamoDB for locking).

---

## 📚 Learn More

- **Terraform Documentation**: https://www.terraform.io/docs/
- **AWS EKS Best Practices**: https://aws.github.io/aws-eks-best-practices/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## Next Steps

1. **Setup Load Balancer**: Deploy AWS Load Balancer Controller
2. **Configure DNS**: Route53 for domain management
3. **SSL Certificates**: cert-manager with Let's Encrypt
4. **Monitoring**: Deploy Prometheus/Grafana to EKS
5. **ArgoCD**: Deploy for GitOps on AWS EKS
6. **Secrets Management**: Integrate AWS Secrets Manager
7. **Backup**: Configure Velero for cluster backups
