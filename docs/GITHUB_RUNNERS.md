# Self-Hosted GitHub Runners on AWS (Optional)

## ⚠️ Do You Need This?

**Use GitHub-hosted runners unless:**
- You need more than 2,000 minutes/month
- You need specific software/hardware
- You need access to private networks
- You have compliance requirements

## 🚀 AWS EC2 Self-Hosted Runner Setup

### 1. Create EC2 Instance

```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=github-runner}]'
```

### 2. Install Runner Software

```bash
# SSH into instance
ssh -i your-key.pem ec2-user@instance-ip

# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Git
sudo yum install -y git

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Create runner directory
mkdir actions-runner && cd actions-runner

# Download runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### 3. Configure Runner

```bash
# Get registration token from GitHub
# Go to: Settings → Actions → Runners → New self-hosted runner

# Configure runner
./config.sh --url https://github.com/YOUR_USERNAME/terraform-vpc-project --token YOUR_TOKEN

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start
```

### 4. Terraform for Self-Hosted Runner

```hcl
# ec2-runner.tf
resource "aws_instance" "github_runner" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type = "t3.medium"
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.runner.id]
  subnet_id              = aws_subnet.public[0].id
  
  user_data = base64encode(templatefile("${path.module}/runner-setup.sh", {
    github_token = var.github_token
    repo_url     = var.repository_url
  }))

  tags = {
    Name = "github-runner"
  }
}

resource "aws_security_group" "runner" {
  name_prefix = "github-runner-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 5. Runner Setup Script

```bash
#!/bin/bash
# runner-setup.sh

yum update -y
yum install -y docker git

systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
mv terraform /usr/local/bin/

# Setup runner as ec2-user
sudo -u ec2-user bash << 'EOF'
cd /home/ec2-user
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
./config.sh --url ${repo_url} --token ${github_token} --unattended
EOF

# Install as service
cd /home/ec2-user/actions-runner
./svc.sh install ec2-user
./svc.sh start
```

### 6. Update Workflow for Self-Hosted

```yaml
jobs:
  deploy:
    runs-on: self-hosted  # Use your runner
    # or
    runs-on: [self-hosted, linux, x64]  # With labels
```

## 💰 Cost Comparison

### GitHub-Hosted (Recommended)
- **Free**: 2,000 minutes/month (private repos)
- **Paid**: $0.008/minute after free tier
- **No maintenance**: Fully managed

### Self-Hosted on AWS
- **EC2**: ~$25/month (t3.medium)
- **Storage**: ~$2/month (20GB)
- **Data Transfer**: Variable
- **Maintenance**: Your responsibility

## 🎯 Recommendation

**Stick with GitHub-hosted runners** because:
- ✅ Your workflows run < 10 minutes each
- ✅ You're likely under 2,000 minutes/month
- ✅ No maintenance overhead
- ✅ Always up-to-date
- ✅ Better security

**Only use self-hosted if:**
- You exceed GitHub's free tier
- You need specific compliance requirements
- You need access to private AWS resources

## 🔧 Current Setup is Perfect

Your current workflows use:
```yaml
runs-on: ubuntu-latest  # GitHub-hosted runner
```

This is the recommended approach for most projects!
