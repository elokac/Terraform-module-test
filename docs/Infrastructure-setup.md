### Infrastructure Documentation

This document provides an overview of the infrastructure setup for the "tf-project" using Terraform. It includes details about the architecture, resources created, and step-by-step instructions on how to reproduce this infrastructure.


## Overview: 3-Tier Architecture and Information Flow
The "tf-project" infrastructure embraces a 3-tier architecture that ensures a clear and secure information flow while promoting isolation between different components. Here's how information flows within this setup:

# Tier 1: Amazon Virtual Private Cloud (VPC) with Public Subnets
# Public Subnets

# Information Flow:
- Public subnets host resources such as Load Balancers, providing a secure entry point for incoming user traffic.
- Load Balancers distribute incoming requests to backend services within the EKS cluster, which is located in the private subnets of Tier 2.

# Importance:
- Public subnets are exposed to the internet and provide an entry point for external user requests.
- They create a secure demilitarized zone (DMZ) for handling incoming traffic.

# Tier 2: Amazon Elastic Kubernetes Service (EKS) Cluster
# EKS Cluster, Application Instances, and Worker Nodes
# Information Flow:

- The EKS cluster, including application instances and worker nodes, is hosted within private subnets.
- It orchestrates containerized applications using Kubernetes and is accessed by administrators and developers via a Bastion Host located in the public subnet.

# Importance:
- The EKS cluster serves as the platform for managing, scaling, and deploying containerized applications.
- It ensures that applications are deployed and run efficiently and securely within the Kubernetes environment.
- Worker nodes run containerized application workloads, enhancing scalability and resource management.

# Tier 3: Amazon Relational Database Service (RDS) for MySQL
# Information Flow:

- The RDS instance, which stores application data, resides in a private subnet.
- It can only be accessed by application instances in the same private subnet or authorized users connecting via the Bastion Host located in the public subnet.

# Importance:
- The RDS instance is shielded from external access, ensuring data security and compliance.
- It provides a trusted repository for application data, with controlled access through a secure channel.

# Secure Access via Bastion Host
# Information Flow:

- Authorized users, including administrators and developers, connect to the Bastion Host in the public subnet.
- The Bastion Host serves as a gateway, allowing secure, controlled access to the EKS cluster and private instances.

# Importance:
- The Bastion Host enforces secure access policies, ensuring that only authorized personnel can reach private resources like the EKS cluster and RDS instance.
- It logs access activities for auditing and monitoring purposes, enhancing security and accountability.

In this revised architecture, both application instances and worker nodes within the EKS cluster are placed in Tier 2, as they reside in private subnets. The Bastion Host and Load Balancers are located in public subnets, serving as the primary entry points for external user traffic and providing secure access to the EKS cluster and other private resources.


## Project Folder Structure
The project's folder structure is organized to maintain separation between infrastructure provisioning and state management. Here's an overview of the key components:

```
├── docs
│   ├── Infra_diagram.png
│   ├── Infrastructure-setup.md
│   └── setup-steps.md
├── tf-project
│   ├── 0-provider.tf
│   ├── 1-vpc-test.tf
│   ├── 2-eks-cluster.tf
│   ├── 3-eks-worker.tf
│   ├── 4-baston-host.tf
│   ├── 5-db.tf
│   ├── 6-ecr.tf
│   ├── output.tf
│   └── variables.tf
└── tfstate-store
    └── tfstate-store.tf
```

1. # docs
   - # Infra_diagram.png: 
       A visual representation of the infrastructure diagram.
   - # Infrastructure-setup.md: 
       Documentation explaining the overall infrastructure setup and architecture.
   - # setup-steps.md: 
       Documentation outlining the step-by-step process to reproduce the infrastructure.
1. # tf-project

   - # 0-provider.tf: 
       Terraform configuration file for provider settings and AWS configuration.
   - # 1-vpc-test.tf: 
       Terraform configuration file for setting up the Amazon Virtual Private Cloud (VPC) and associated resources.
   - # 2-eks-cluster.tf: 
       Terraform configuration file for creating the Amazon Elastic Kubernetes Service (EKS) cluster.
   - # 3-eks-worker.tf: 
       Terraform configuration file for provisioning worker nodes within the EKS cluster.
   - # 4-baston-host.tf: 
       Terraform configuration file for launching the Bastion Host in the public subnet.
   - # 5-db.tf: 
       Terraform configuration file for setting up the Amazon Relational Database Service (RDS) for MySQL.
   - # 6-ecr.tf: 
       Terraform configuration file for configuring the Elastic Container Registry (ECR).
   - # output.tf: 
       Terraform configuration file for defining outputs that can be useful for post-deployment tasks.
   - # variables.tf: 
       Terraform configuration file for defining variables used throughout the project.

1. # tfstate-store

   - # tfstate-store.tf: 
       Terraform configuration file for configuring the backend state storage, including an S3 bucket and DynamoDB table.
## Important Notes
- # State Management: 
    The tfstate-store directory is vital as it contains the Terraform backend configuration responsible for storing state files. Ensure that this state store is set up correctly before provisioning any infrastructure using Terraform.

# - Documentation: 
    The docs directory provides valuable documentation, including an infrastructure diagram, setup instructions, and an explanation of the architecture. Review and follow these documents for a comprehensive understanding of the infrastructure and the steps to reproduce it.

By adhering to this structured folder arrangement, you can maintain a clear distinction between infrastructure provisioning and state management, making the project organized and easy to maintain.

#####################################
Steps to Reproduce
To reproduce this infrastructure setup, follow these steps:

Prerequisites
Before you begin, ensure you have the following prerequisites:

AWS CLI: Install and configure the AWS Command Line Interface with appropriate credentials.
Terraform: Install Terraform on your local machine.
Clone the Repository
Clone the GitHub repository to your local machine:

bash
Copy code
git clone <repository_url>
Navigate to the "tf-project" directory:

bash
Copy code
cd tf-project
Configure Terraform
Initialize Terraform and download required providers:

bash
Copy code
terraform init
Create the Infrastructure
Review and adjust variables in the variables.tf file if needed to match your requirements.

Execute Terraform plan to view the changes that will be applied:

bash
Copy code
terraform plan
Apply the changes to create the infrastructure:

bash
Copy code
terraform apply
Terraform will prompt for confirmation before making any changes.

Accessing the Infrastructure
Once the Terraform apply is complete, the infrastructure will be provisioned on AWS.

Access the AWS Management Console to view the created resources.

Destroy the Infrastructure (Optional)
To destroy the infrastructure and release AWS resources, run:

bash
Copy code
terraform destroy
Be cautious when using this command, as it will permanently delete resources.

Additional Information
Refer to the Terraform configuration files in the "tf-project" directory for details on resource definitions and configurations.

The "tfstate-store" directory contains Terraform state files used to maintain the state of the infrastructure. Keep these files secure and do not commit them to version control.

For any issues, refer to the Terraform documentation and AWS documentation for troubleshooting and further information.

This documentation provides a high-level overview of the infrastructure setup and steps to reproduce it. Ensure you have a good understanding of AWS and Terraform before proceeding.