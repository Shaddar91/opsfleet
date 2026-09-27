controller:
  region: ${jsonencode(region)}
  serviceAccount:
    name: ${jsonencode(service_account)}
node:
  tolerateAllTaints: true
storageClasses: []
defaultStorageClass:
  enabled: false
