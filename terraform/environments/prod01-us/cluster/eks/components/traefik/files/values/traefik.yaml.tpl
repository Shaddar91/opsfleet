deployment:
  kind: Deployment
  replicas: 2
  terminationGracePeriodSeconds: 60
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: '{{ template "traefik.name" . }}'
        app.kubernetes.io/instance: '{{ include "traefik.instance-name" . }}'
service:
  nameOverride: ${jsonencode(service_name)}
  spec:
    type: ClusterIP
ports:
  traefik:
    port: ${traefik_port}
  web:
    port: ${web_port}
    forwardedHeaders:
      trustedIPs: ${jsonencode([vpc_cidr])}
  websecure:
    forwardedHeaders:
      trustedIPs: ${jsonencode([vpc_cidr])}
