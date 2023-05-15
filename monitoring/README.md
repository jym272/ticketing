## Monitoring
Basic config for monitoring with prometheus and grafana.
[Reference](https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/)

#### Apply monitoring config with:
```shell
kubectl apply -k monitoring
```

#### Some useful queries for prometheus:
```text
sum by(pod) (container_memory_usage_bytes{namespace="default",pod=~"auth-.*|orders-.*|tickets-.*|payments-.*|expiration-.*|frontend-.*"})

sum by (pod) (
  rate(
    container_cpu_usage_seconds_total{namespace="default",pod=~"auth-.*|orders-.*|tickets-.*|payments-.*|expiration-.*|frontend-.*"}[1m]
  )
)
```