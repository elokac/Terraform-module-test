resource "aws_iam_role" "eks-cluster" {
  name = "IAM-Role-For-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster.name
}

#Security Group
resource "aws_security_group" "cluster-sg" {
  name        = "clusterSG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.new-test.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "EKScluster-sg"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster-sg.id
  source_security_group_id = aws_security_group.worker-node-sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-bastion-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Bastion-host to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

#EKS Service
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-subnet-1.id,
      aws_subnet.private-subnet-2.id,
      aws_subnet.public-subnet-1.id,
      aws_subnet.public-subnet-2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy
  ]

  tags = {
    Name        = "${var.project}-EKScluster"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}