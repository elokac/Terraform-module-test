resource "aws_iam_role" "worker-nodes" {
  name = "IAM-Role-${var.project}-worker-node"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-nodes.name
}

#Security Group
resource "aws_security_group" "worker-node-sg" {
  name        = "worker-nodeSG"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.new-test.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                   = "worker-node-sg"
    "kubernetes.io/cluster/" = var.cluster_name
    project                  = var.project
    createdby                = var.createdby
    environment              = lookup(var.environment, terraform.workspace)
    manager                  = element(var.manager, 0)
  }
}

resource "aws_security_group_rule" "worker-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker-node-sg.id
  source_security_group_id = aws_security_group.worker-node-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-node-sg.id
  source_security_group_id = aws_security_group.cluster-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_eks_node_group" "worker-nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  version         = var.cluster_version
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.worker-nodes.arn

  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-worker-node-policy,
    aws_iam_role_policy_attachment.amazon-eks-cni-policy,
    aws_iam_role_policy_attachment.amazon-ec2-container-registry-read-only,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  tags = {
    Name        = "${var.project}-EKS-NodeGroup"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}