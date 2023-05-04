
locals {
  vpc = {
    name = "${local.cluster_name}-vpc"
    cidr = "10.0.0.0/16" # ->  	10.0.0.0 to 10.0.255.255 -> 65,536 addresses
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name            = local.vpc.name
  cidr            = local.vpc.cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = local.vpc.private_subnets # workers in the private subnets with a default route to NAT Gateway
  public_subnets  = local.vpc.public_subnets  # bastion in the public subnets with a default route to the Internet Gateway

#  enable_ipv6                     = true
#  assign_ipv6_address_on_creation = true
  create_egress_only_igw          = true

#  public_subnet_ipv6_prefixes  = [0, 1, 2]
#  private_subnet_ipv6_prefixes = [3, 4, 5]

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared" # e. The shared value allows more than one cluster to use the subnet.
    #  allow Kubernetes to use only tagged subnets for external load balancers
    "kubernetes.io/role/elb" = "1" # aws-lb controller looks for this tag
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared" # e. The shared value allows more than one cluster to use the subnet.
    # allow Kubernetes to use your private subnets for internal load balancers
    "kubernetes.io/role/internal-elb" = "1" # aws-lb controller looks for this tag
  }

  enable_nat_gateway     = true  # NAT Gateway for each Private Subnet
  single_nat_gateway     = true  # only one NAT Gateway for all Private Subnets
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = {
    Environment = var.environment
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.17.0"

  role_name = "vpc-cni-irsa"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
#  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = {
    Environment = var.environment
  }
}
