sum by(pod) (container_memory_usage_bytes{namespace="default",pod=~"auth-.*|orders-.*|tickets-.*|payments-.*|expiration-.*"})

sum by (pod) (
  rate(
    container_cpu_usage_seconds_total{namespace="default",pod=~"auth-.*|orders-.*|tickets-.*|payments-.*|expiration-.*"}[1m]
  )
)