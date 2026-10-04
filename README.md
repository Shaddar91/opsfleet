# Innovate Inc. on AWS

The cloud design for Innovate Inc. and the Terraform that builds it: two regions, EKS with Karpenter on x86 and Graviton, an Aurora PostgreSQL global database and regional failover behind Global Accelerator.

## Contents

- [Architecture](architecture/README.md): the target design, from the account structure to disaster recovery
  - [Summary](architecture/README.md#summary)
  - [Where we are and where we want to be](architecture/README.md#where-we-are-and-where-we-want-to-be)
  - [Cloud environment structure](architecture/README.md#cloud-environment-structure)
  - [Network design](architecture/README.md#network-design): [VPC architecture](architecture/README.md#vpc-architecture), [securing the network](architecture/README.md#securing-the-network)
  - [Compute platform](architecture/README.md#compute-platform): [Kubernetes](architecture/README.md#kubernetes-deploying-and-managing-the-application), [node groups and scaling](architecture/README.md#node-groups-scaling-and-resource-allocation), [containerization](architecture/README.md#containerization-image-building-registry-deployment)
  - [Database](architecture/README.md#database): [PostgreSQL service](architecture/README.md#postgresql-service-and-why), [backups, high availability, disaster recovery](architecture/README.md#backups-high-availability-disaster-recovery)
  - [Improvements](architecture/README.md#improvements)
  - [Glossary](architecture/README.md#glossary)
  - Diagrams: [system](architecture/InnovationInc-System-Diagram.png), [AWS Organization](architecture/InnovateInc-Organization.png)
- [Terraform](terraform/README.md): what the code builds and how to run it
  - [What it builds](terraform/README.md#what-it-builds)
  - [Layout](terraform/README.md#layout)
  - [Prerequisites](terraform/README.md#prerequisites)
  - [Run it](terraform/README.md#run-it)
  - [Run it from GitHub Actions](terraform/README.md#run-it-from-github-actions)
  - [Run a pod on x86 or Graviton](terraform/README.md#run-a-pod-on-x86-or-graviton)
  - [Tear down](terraform/README.md#tear-down)
  - [How to deploy](terraform/README.md#how-to-deploy)
  - [Command sheet for the region scripts](terraform/environments/innovate-inc/README.md): [secrets](terraform/environments/innovate-inc/README.md#secrets-first), [a region](terraform/environments/innovate-inc/README.md#a-region), [after a failure](terraform/environments/innovate-inc/README.md#after-a-failure), [system tiers](terraform/environments/innovate-inc/README.md#system-tiers), [messages and what to do](terraform/environments/innovate-inc/README.md#messages-and-what-to-do)
- [Related repositories](#related-repositories)

## Where things are

| Folder | What is in it |
|---|---|
| [architecture/](architecture/) | The design document and its two diagrams |
| [terraform/environments/innovate-inc/](terraform/environments/innovate-inc/) | The stacks of each region (`prod01-us-east-1`, `prod01-us-west-2`) and the global ones (`global/`: CloudFront site, Global Accelerator) |
| [terraform/system/](terraform/system/) | Account-wide stacks: buckets, Route 53, IAM, SSH key, ECR, GitHub repositories, developer access, secret store |
| [terraform/modules/](terraform/modules/) | The versioned modules the stacks call, as `<area>/<name>-<version>` |
| [.github/workflows/terraform.yml](.github/workflows/terraform.yml) | Runs one stack by hand: plan, then apply once approved |

## Related repositories

The applications and charts this platform runs. The Terraform here writes their CI workflows.

| Repository | What it is |
|---|---|
| [of-api](https://github.com/Shaddar91/of-api) | Flask REST API, image built for amd64 and arm64 |
| [of-web](https://github.com/Shaddar91/of-web) | React (Vite) web app, served by CloudFront |
| [of-load](https://github.com/Shaddar91/of-load) | Stress API for pod and node autoscaling tests |
| [of-helm](https://github.com/Shaddar91/of-helm) | Helm charts Argo CD deploys, with x86 and Graviton values |
| [of-failover](https://github.com/Shaddar91/of-failover) | Lambda that fences a region on Global Accelerator and promotes the Aurora standby |
| [of-launch](https://github.com/Shaddar91/of-launch) | Deployment dashboard: Flask, MySQL, CodeDeploy |
