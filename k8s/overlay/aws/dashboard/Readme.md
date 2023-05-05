
tutorial https://blog.saeloun.com/2023/03/21/setup-kubernetes-dashboard-eks/
last version https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ && helm repo update
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard


```text
NAME: kubernetes-dashboard
LAST DEPLOYED: Thu May  4 19:43:33 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************

Get the Kubernetes Dashboard URL by running:
export POD_NAME=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
echo https://127.0.0.1:8443/
kubectl -n default port-forward $POD_NAME 8443:8443

```


kubectl apply -f eks-admin-service-account.yaml

kubectl create token eks-admin -n kube-system

eyJhbGciOiJSUzI1NiIsImtpZCI6ImU2NzVmMzE1MThlZDU5MTVkYTBiMmU3N2E0MjgxNWU1ZTIzNWExOGEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjIl0sImV4cCI6MTY4MzI0NDI4NywiaWF0IjoxNjgzMjQwNjg3LCJpc3MiOiJodHRwczovL29pZGMuZWtzLnNhLWVhc3QtMS5hbWF6b25hd3MuY29tL2lkL0YzNjUyNzM2QTcyMzAzREY0QTAxRTA0MEZDNjhDMkU5Iiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJla3MtYWRtaW4iLCJ1aWQiOiJjM2QzMTAzOC1iNTgyLTQ1Y2ItOTcwNC04NGFiNzhhOGM4NzAifX0sIm5iZiI6MTY4MzI0MDY4Nywic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmVrcy1hZG1pbiJ9.O_xerRtH1G3IwCrzgBwaiSz-uE8qpdUfjMjFqbQ5KW53xTLe6VnaVUOWEoJFdnN-dib6qihLlF8-JtdrmA26lrPhoLxX0VpnTdLuKyz9x0mTYV3am7wJHd493194P89OUj_RG5Ka4Je_Eh6Go8n2tZ-h5zSSZveVr5qRu9BajKfGsT6oLRIErnFnuE0Sgb7OyN2leCwto9vqNN8Azv2JBLBZgA-C6WgNt8waKesERCQcv8bqgqhr_r6lxOpOJLj1rvqhWHlhT0b_OXxPbkW2ECqU_QB8B62guHrbr0Ki6p83pnP8YCVnfvj3miOs3gchJyZ4xNyRRTCKoY5cSvbDuQ


export POD_NAME=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
echo https://127.0.0.1:8443/  # visit here and paste token
kubectl -n default port-forward $POD_NAME 8443:8443


////# or using kubectl proxy: and later
http://localhost:8001/api/v1/namespaces/default/services/https:kubernetes-dashboard:https/proxy/