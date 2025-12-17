Architecture 

┌─────────────────────────────────────────┐
│         HTTP Request                    │
└────────────────┬────────────────────────┘
                 │
     ┌───────────▼───────────┐
     │  Go Application       │
     │  (Port 8080)          │
     ├───────────────────────┤
     │ Runs as: appuser      │
     │ UID: 1000             │
     │ Non-root              │
     └───────────┬───────────┘
                 │
     ┌───────────▼───────────────────────┐
     │  Docker Container                 │
     │  Alpine Linux                     │
     │  Go Binary                        │
     │  SSL Cer                          │
     └───────────────────────────────────┘



# Make sure you have main.go file and Dockerfile in app  directory

cd app/

### Build the Docker image:

docker build -t simpletimeservice:1.0.0 .

### Run the container:

docker run -d -p 8080:8080 --name time-service simpletimeservice:1.0.0

### Test endpoint

curl localhost:8080/health
{"status":"healthy"}

curl localhost:8080
{"timestamp":"2025-12-17T08:52:12Z","ip":"192.168.65.1:46150"}

### Push the image to docker hub 
docker login 

docker tag simpletimeservice:1.0.0 vishal26778/simpletimeservice:1.0.0

docker push vishal26778/simpletimeservice:1.0.0

### Now use below command to pull from docker hub command and run into local

docker pull vishal26778/simpletimeservice:1.0.0
docker run -d -p 8080:8080 --name time-service vishal26778/simpletimeservice:1.0.0

### Test using below commands 

curl localhost:8080
{"timestamp":"2025-12-17T08:52:12Z","ip":"192.168.65.1:46150"}


curl localhost:8080/health
{"status":"healthy"}


### Infra using Terraform 

### VPC with below subneys

2 Public Subnets for ALB: 10.0.1.0/24 (AZ-1a), 10.0.2.0/24 (AZ-1b)
2 Private Subnets for EKS nodes: 10.0.10.0/24 (AZ-1a), 10.0.11.0/24 (AZ-1b)
2 NAT Gateways (1 per AZ for HA)
1 Internet Gateway for internet access

### EKS Cluster with ALB 

EKS and node group setup in Private subnets 
ALB in Public Subnet 


### Commands 

cd terraform 

terraform init

terraform plan -var-file=terraform.tfvars

terraform apply -var-file=terraform.tfvars



Request flow 

Internet (443 HTTPS)
    ↓
Route53 DNS (app.particle41.com)
    ↓
ALB (with ACM certificate)
    ↓
EKS Pods (private subnets)

### Worklow for CI Flow 

Add below secrets in Github Setting of repository 

DOCKERHUB_USERNAME
DOCKERHUB_TOKEN

Code Push / PR
     ↓
Docker Build
     ↓
Trivy Security Scan
     ↓
Docker Hub Push
