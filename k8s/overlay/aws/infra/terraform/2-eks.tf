resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name    = "${var.cluster.prefix_name}-${random_string.suffix.result}"
  cluster_version = "1.24"
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

resource "aws_security_group" "additional" {
  name_prefix = "${local.cluster_name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

#  cluster_ip_family = "ipv6"

#  create_cni_ipv6_iam_policy = true

  cluster_addons = {
    coredns = {
      most_recent = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      resolve_conflicts = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  cluster_tags = {
    # This should not affect the name of the cluster primary security group
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2006
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2008
    Name = local.cluster_name
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # grant access to your applications running in the EKS cluster
  # IAM Roles for Service Accounts. In that way, you can limit the IAM role to a single pod
  enable_irsa = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
#  node_security_group_ntp_ipv6_cidr_block = ["fd00:ec2::123/128"]


  node_security_group_additional_rules = {
    #open ports between nodes https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1812
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # all validating/mutating webhooks https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1748#issuecomment-1050231374
    # can also use custom rules for opening port in webhooks
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # custom rule: load balancer controller webhook
#    ingress_allow_access_from_control_plane = {
#      type                          = "ingress"
#      protocol                      = "tcp"
#      from_port                     = 9443
#      to_port                       = 9443
#      source_cluster_security_group = true
#      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
#    }
    # custom rule: webhook "validate.nginx.ingress.kubernetes.io"  open the 8443 port from the master to the pods.
#    ingress_admission_webhook_controller = {
#      type                          = "ingress"
#      protocol                      = "tcp"
#      from_port                     = 8443
#      to_port                       = 8443
#      source_cluster_security_group = true
#      description                   = "Allow access from control plane to webhook Admission Webhook Controller"
#    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    #    disk_size = 50
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
#    complete = {
#      name            = "complete-eks-mng"
#      use_name_prefix = true
#
#      subnet_ids = module.vpc.private_subnets
#
#      min_size     = 1
#      max_size     = 7
#      desired_size = 3
#
#      ami_id                     = data.aws_ami.eks_default.image_id
#      enable_bootstrap_user_data = true
#      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"
#
#      pre_bootstrap_user_data = <<-EOT
#      export CONTAINER_RUNTIME="containerd"
#      export USE_MAX_PODS=false
#      EOT
#
#      post_bootstrap_user_data = <<-EOT
#      echo "you are free little kubelet!"
#      EOT
#
#      capacity_type        = "ON_DEMAND"
#      force_update_version = true
#      instance_types       = ["t3.small"] #["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#      labels = {
#        GithubRepo = "terraform-aws-eks"
#        GithubOrg  = "terraform-aws-modules"
#      }
#
##      taints = [
##        {
##          key    = "dedicated"
##          value  = "gpuGroup"
##          effect = "NO_SCHEDULE"
##        }
##      ]
#
#      update_config = {
#        max_unavailable_percentage = 50 # or set `max_unavailable`
#      }
#
#      description = "EKS managed node group example launch template"
#
##      ebs_optimized           = true
#      vpc_security_group_ids  = [aws_security_group.additional.id]
#      disable_api_termination = false
#      enable_monitoring       = true
#
##      block_device_mappings = {
##        xvda = {
##          device_name = "/dev/xvda"
##          ebs = {
##            volume_size           = 75
##            volume_type           = "gp3"
##            iops                  = 3000
##            throughput            = 150
##            encrypted             = true
##            kms_key_id            = aws_kms_key.ebs.arn
##            delete_on_termination = true
##          }
##        }
##      }
#
#      metadata_options = {
#        http_endpoint               = "enabled"
#        http_tokens                 = "required"
#        http_put_response_hop_limit = 2
#        instance_metadata_tags      = "disabled"
#      }
#
#      create_iam_role          = true
#      iam_role_name            = "eks-managed-node-group-complete-example"
#      iam_role_use_name_prefix = false
#      iam_role_description     = "EKS managed node group complete example role"
#      iam_role_tags = {
#        Purpose = "Protector of the kubelet"
#      }
#      iam_role_additional_policies = [
#        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#      ]
#
#      create_security_group          = true
#      security_group_name            = "eks-managed-node-group-complete-example"
#      security_group_use_name_prefix = false
#      security_group_description     = "EKS managed node group complete example security group"
#      security_group_rules = {
#        phoneOut = {
#          description = "Hello CloudFlare"
#          protocol    = "udp"
#          from_port   = 53
#          to_port     = 53
#          type        = "egress"
#          cidr_blocks = ["1.1.1.1/32"]
#        }
#        phoneHome = {
#          description                   = "Hello cluster"
#          protocol                      = "udp"
#          from_port                     = 53
#          to_port                       = 53
#          type                          = "egress"
#          source_cluster_security_group = true # bit of reflection lookup
#        }
#      }
#      security_group_tags = {
#        Purpose = "Protector of the kubelet"
#      }
#
#      tags = {
#        ExtraTag = "EKS managed node group complete example"
#      }
#    }
    general = {
      desired_size = 3
      min_size     = 3
      max_size     = 10

      subnet_ids = module.vpc.private_subnets
      vpc_security_group_ids  = [aws_security_group.additional.id]
      enable_monitoring       = true

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]


      create_security_group          = true
      security_group_name            = "eks-managed-node-group-complete-example"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group complete example security group"
      security_group_rules = {
        phoneOut = {
          description = "Hello CloudFlare"
          protocol    = "udp"
          from_port   = 53
          to_port     = 53
          type        = "egress"
          cidr_blocks = ["1.1.1.1/32"]
        }
        phoneHome = {
          description                   = "Hello cluster"
          protocol                      = "udp"
          from_port                     = 53
          to_port                       = 53
          type                          = "egress"
          source_cluster_security_group = true # bit of reflection lookup
        }
      }
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }
    }

#    spot = {
#      desired_size = 1
#      min_size     = 1
#      max_size     = 10
#
#      labels = {
#        role = "spot"
#      }
#
#      taints = [{
#        key    = "market"
#        value  = "spot"
#        effect = "NO_SCHEDULE"
#      }]
#
#      instance_types = ["t3.micro"]
#      capacity_type  = "SPOT"
#    }
  }

  manage_aws_auth_configmap = true
  # grant access to the IAM role just once using the aws-auth configmap,
  # and then simply allow users outside of EKS to assume that role and grant access to Kubernetes to your team members.
  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = var.environment
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster" "default" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
}
# authorize terraform to access Kubernetes API and modify aws-auth configmap
provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.default.token
  #  retrieve token on each terraform run.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.17.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${local.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  tags = {
    Environment = var.environment
  }
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = local.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.18.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

