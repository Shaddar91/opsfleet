MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

%{ if CUSTOM_AMI ~}
--==MYBOUNDARY==
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${CLUSTER_NAME}
    apiServerEndpoint: ${API_SERVER_ENDPOINT}
    certificateAuthority: ${CERTIFICATE_AUTHORITY}
    cidr: ${SERVICE_CIDR}
%{ if length(KUBELET_FLAGS) > 0 ~}
  kubelet:
    flags:
%{ for flag in KUBELET_FLAGS ~}
      - ${flag}
%{ endfor ~}
%{ endif ~}

%{ endif ~}
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -euo pipefail
hostnamectl set-hostname "${ENVIRONMENT}-${APPLICATION}-${lower(replace(CAPACITY_TYPE, "_", "-"))}-${NODE_GROUP_NAME}"

--==MYBOUNDARY==--
