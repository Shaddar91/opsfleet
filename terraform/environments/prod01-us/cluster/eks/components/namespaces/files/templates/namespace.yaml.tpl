apiVersion: v1
kind: Namespace
metadata:
  name: ${jsonencode(name)}
%{ if length(labels) > 0 ~}
  labels:
%{ for key, value in labels ~}
    ${jsonencode(key)}: ${jsonencode(value)}
%{ endfor ~}
%{ endif ~}
%{ if length(annotations) > 0 ~}
  annotations:
%{ for key, value in annotations ~}
    ${jsonencode(key)}: ${jsonencode(value)}
%{ endfor ~}
%{ endif ~}
