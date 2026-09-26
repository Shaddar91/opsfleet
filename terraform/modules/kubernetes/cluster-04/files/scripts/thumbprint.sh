#!/bin/bash

THUMBPRINT=$(openssl s_client -servername oidc.eks.us-east-1.amazonaws.com -connect oidc.eks.us-east-1.amazonaws.com:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin | cut -d '=' -f 2 | tr -d ':'
)
echo "{\"thumbprint\": \"$THUMBPRINT\"}"
