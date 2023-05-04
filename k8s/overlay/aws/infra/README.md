## Architecture Diagram
![Diagram](assets/architecture_diagram.png?raw=true "Architecture Diagram")

You can find tutorial [here](https://antonputra.com/mazon/create-eks-cluster-using-terraform-modules/).


#### Connect to EKS Cluster
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Help Links

- [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)




referise a este readme desde el otro readme
volumes must be deleted manually
choose az to deploy