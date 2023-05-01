### Digital Ocean Overlay
[Ref]
- Kubernetes server
- Install ingress}
- Configure domain, the domain must be  "A" record pointing to LB IP
  - The rest of subdomains are CNAME record that point to domain @
- Install cert manager

- When delete resources, the volumes must be deleted manually `kubectl get pvc`
  - [Reference](https://docs.digitalocean.com/products/kubernetes/how-to/add-volumes/)


[Ref]: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm
