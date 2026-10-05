# Innovate Inc. cloud architecture

## Contents

- [Summary](#summary)
- [Where we are and where we want to be](#where-we-are-and-where-we-want-to-be)
- [Cloud environment structure](#cloud-environment-structure)
  - [Why this split: isolation, billing, management](#why-this-split-isolation-billing-management)
- [Network design](#network-design)
  - [VPC architecture](#vpc-architecture)
  - [Securing the network](#securing-the-network)
- [Compute platform](#compute-platform)
  - [Kubernetes: deploying and managing the application](#kubernetes-deploying-and-managing-the-application)
  - [Node groups, scaling and resource allocation](#node-groups-scaling-and-resource-allocation)
  - [Containerization: image building, registry, deployment](#containerization-image-building-registry-deployment)
- [Database](#database)
  - [PostgreSQL service and why](#postgresql-service-and-why)
  - [Backups, high availability, disaster recovery](#backups-high-availability-disaster-recovery)
- [Observability](#observability)
  - [Network and placement](#network-and-placement)
  - [What we collect and where it goes](#what-we-collect-and-where-it-goes)
  - [Analytics](#analytics)
- [Improvements](#improvements)
- [Glossary](#glossary)

## Summary
Innovate Inc. runs a React single-page app, a Flask REST API and a PostgreSQL database, and we put it on AWS. The design is one AWS Organization of ten accounts, so that environments, evidence, backups and shared tooling sit behind hard boundaries. The application runs on EKS, with Karpenter adding and removing x86 and Graviton nodes on Spot and On-Demand capacity. The database is Aurora PostgreSQL  replicated to a second region. People sign in once through IAM Identity Center, and every change to production is a commit plus a pipeline run. Today everything is built by the Terraform in terraform/ inside one AWS account; the organization, the identity layer and the detection services are the proposal.

## Where we are and where we want to be

Today the Terraform in terraform/ builds the system in one Amazon Web Services (AWS) account and two regions, us-east-1 and us-west-2. Global Accelerator sits in front and sends users to us-east-1, or to us-west-2 when us-east-1 is down. The database runs in us-east-1, with a read-only copy in us-west-2 as an Aurora global database. A Lambda function in us-west-2 takes us-east-1 out of traffic and promotes the copy. That is disaster recovery (DR) at the level of regions: when one region fails, the other carries on.

The target takes the same idea one level up, to accounts. A second region protects us from a region going down. Separate accounts protect us from what goes wrong inside one account: a leaked pipeline key, a deleted database, a load test that uses up a quota, a person with more access than the job needs. Each of those stays inside the account where it happened. So the one account becomes an AWS Organization of ten accounts in organizational units (OUs), shown in the next section. Both regions stay together inside the Prod account. The Backup account does for the data what the second region does for traffic: its copies survive even someone taking over Prod.

## Cloud environment structure
Innovate Inc. needs an AWS Organization with organizational units (OUs). The brief asks for a secure, scalable and cost-effective setup that can grow to millions of users, so we split the system into separate AWS accounts and group them in OUs. If a compliance requirement shows up later (SOC 2, HIPAA, PCI), the structure already fits and needs little or no change.

An account is the hard boundary in AWS. IAM, blast radius, quotas and billing all stop at the account; Accounts cannot be merged or split later without rebuilding what is inside, so we create the full structure now, and Terraform creates and baselines every account.

The organizational units:

Root
  Management: owns the organization, nothing else runs here
  Security OU
    Log Archive: all logs and audit trails, nobody logs in here
    Security Tooling: the security team's account, the SIEM, alerting, the Falcon tenant
  Infrastructure OU
    Shared Services: container registry, parent DNS zone, Terraform state, CI roles, the Elastic Stack, Prometheus, Thanos, Grafana
    Transit: the transit network, the Transit Gateways every VPC attaches to
    Backup: the backup vault, cut off from Prod
  Workloads OU
    NonProd OU
      Dev
      Staging
    Prod OU
      Prod: the users and their data
      Analytics: PostHog, what the users do in the web app

Ten accounts in five OUs.

Management only owns the organization. The organization rules below do not apply to it, so nothing runs in it. Log Archive holds the evidence and has to survive a break-in anywhere else. Security Tooling is where the security team works; it is a separate account from Log Archive so the account with the strongest cross-account roles does not also hold the logs. Shared Services has the tooling every environment uses and holds no user data. Backup is separate from Shared Services so a compromised pipeline cannot reach the backups. Transit holds the transit network, a Transit Gateway in each region that every VPC attaches to, so the clusters reach the observability stack without leaving the AWS network; the Observability section has the design. Dev is a real deployment of the product with synthetic data. Staging is the release gate, with the same IAM setup as Prod and its own quotas, so load tests do not hit Dev. Prod serves the users and holds their data; the second region is in this account too. Analytics holds PostHog, what the users do in the web app; it sits under the Prod OU because that is user data, in an account of its own so a fault in the analytics stack never reaches the application. One optional account can come later. A Data Engineering account, in its own Data OU under Workloads, receives production data through CDC, ETL or ELT pipelines that strip or mask the sensitive fields, so the data team works without touching regulated data. Three OUs are reserved and not created on day one: Sandbox for per-engineer accounts with a hard budget and no path to Prod, PolicyStaging where a new rule is attached first, Suspended for closed accounts under a deny-all rule for 90 days.

With this we have segregation of duties: full control over who has access to what.

Nobody has standing access to these accounts. The risk is a session that does: an over-privileged deploy role, a leaked pipeline key, a BreakGlass window. For that case, rules attached above the accounts set a ceiling no role or admin inside can raise; AWS calls them service control policies. Whatever rights the session holds, it cannot: take the account out of the organization; stop or change CloudTrail, Config, GuardDuty or Security Hub; create anything outside our two regions; use the account's root login; create IAM users or access keys; delete KMS keys, except through BreakGlass; change the Log Archive buckets, their locks or their keys; make production databases, disks or images public, or delete their backups. A second rule, a resource control policy, makes our buckets, keys, secrets and queues refuse any caller from outside the organization, so a leaked key used from outside gets nothing. A tag policy requires Environment, Owner and CostCenter on every resource; a backup policy runs the production backup plan and copies it to the Backup vault in the DR region; a declarative policy turns on IMDSv2 by default. NonProd carries only the organization-wide ceiling, so developers keep room to work in Dev.

Access. Every user exists once, in the company directory, e.g. Google Workspace; Okta or Microsoft Entra work the same way. IAM Identity Center, the AWS single sign-on, imports the users and groups from there. The instance lives in the Management account and is administered from Security Tooling, so nobody works in Management. There are no IAM users anywhere; the Root rule blocks creating them. A user is put in a group, and the group gets a permission set in each account it may use. A permission set is a role: Identity Center creates it in every account it is assigned to. To work in an account, the user runs aws sso login with the profile for that account. The CLI opens the browser once, the user signs in with the company login and MFA, and the CLI gets one-hour credentials for the role, configurable up to twelve hours. Terraform and kubectl use the same session. No access keys on laptops; a leaver is disabled in the directory and every session dies with it. MFA is enforced at login by the directory: an authenticator code or a FIDO2 hardware key. Setup once per profile: aws configure sso, then aws sso login.

Permission sets:

OrgAdmin: Management only, two named people. Organization, billing, Control Tower.
PlatformAdmin: Shared Services, Security Tooling, Dev. Platform engineers. Admin on the platform tooling and on Dev.
Developer: Dev. Deploy, kubectl write in the cluster, read logs. No IAM changes.
SecurityAnalyst: full access to the security services in Security Tooling, read-only in Log Archive.
ReadOnly: every account, everyone technical. View-only AWS, read logs, read-only kubectl.
BreakGlass: Staging, Prod and Backup. Admin access. Its group is empty by default; a named approver adds a person for a time-boxed window, every use pages the security team and gets a post-incident review.

Staging and Prod have no human write access. An infrastructure change is a pull request with a plan, applied on merge by the pipeline role. An application change is a commit to the GitOps repository that Argo CD pulls from inside the cluster.

Audit and alerts. One organization CloudTrail trail records every action in every account and delivers it to Log Archive, where S3 Object Lock keeps it from being altered or deleted. Three kinds of events alert: a root user login, a BreakGlass assumption, and a GuardDuty or Security Hub finding. Each alert goes by email and to a dedicated Slack channel that the SOC, DevOps and platform teams read. The person who triggered it acknowledges with a reaction on the Slack message and replies to the email; if nobody acknowledges within N minutes, the SOC treats it as an incident and acts. Severity picks the channel: critical and high page through PagerDuty, medium and low go to Slack, compliance failures open a ticket. Only Security Tooling sends security notifications.

Log Archive and Security Tooling are two accounts, and that is on purpose. Log Archive holds what nobody reads daily: CloudTrail, Config history, VPC flow logs, load balancer and CloudFront access logs, Security Lake. Only AWS services write to it, nobody logs in day to day, and a SecurityAnalyst gets read-only access during an investigation. Security Tooling holds the SIEM, the admin of the security services (GuardDuty, Security Hub, Inspector, Macie, Config, IAM Access Analyzer) and the alert routing, and the security team works there. Application logs and metrics, the things on-call reads daily, land in buckets here too, the copies we own, and the observability stack in Shared Services reads them back; the Observability section has the design.

###### Why this split: isolation, billing, management

Billing and management. Consolidated billing sits in Management, so every account is its own cost line in Cost Explorer with no tagging work. Savings Plans bought there are shared across the organization. Every account gets a monthly budget that alerts at 50, 80 and 100 percent, and Cost Anomaly Detection runs for the whole organization. Accounts, OUs, Control Tower, Identity Center and the organization rules cost nothing; Config, GuardDuty, Security Hub, Inspector, Macie, CloudTrail data events, Security Lake storage and the Backup vault are paid by volume. One Terraform stack creates the Control Tower landing zone, the OUs, the policies, the delegated administrators and the accounts, and every new account gets the same baseline module.



## Network design

### VPC architecture

Every workload account has one virtual private cloud (VPC), its private network, per region, with three subnet tiers set apart by what may reach the internet: public, private and internal. Each VPC spans every Availability Zone (AZ) the region allows, separate data centers of one region: five in us-east-1, where EKS does not accept the sixth, and four in us-west-2. Losing one zone then costs the smallest possible share of capacity. Every tier has one subnet per zone, each with its own address block, and no two blocks overlap.

Public subnets are the only ones where anything may have a public Internet Protocol (IP) address. They hold only what faces the internet: the public load balancers and the network address translation (NAT) gateways. Their route table leads to the internet gateway, the VPC's door to the internet.

Private subnets hold the nodes and pods of the Amazon Elastic Kubernetes Service (EKS) cluster, the internal load balancer, and RDS Proxy, the connection pool in front of the database. Nothing here may have a public IP address. They go out through the NAT gateways, and nothing on the internet can open a connection in.

Internal subnets hold the databases and nothing else. Their route table has no way out: no internet gateway, no NAT gateway, only a VPC endpoint, a private path to Amazon Simple Storage Service (S3). That is why we want them. A database made public by mistake still cannot be reached from the internet. Nothing in these subnets can send data to the internet either, because no route leads there.

Subnet sizes follow the EKS cluster. Through the VPC Container Network Interface (CNI) plugin, every pod takes its own address from the private subnet, so pods use up addresses faster than anything else. The private tier gets the largest share of the VPC's /16, cut into equal blocks, one per zone. The public and internal tiers get a /22 per zone, and the rest stays free. More zones means a smaller block per zone; if the pods ever outgrow the private tier, the VPC adds a second range for pods only, from 100.64.0.0/10 (reserved).

Every VPC takes its range from one organization pool in Amazon VPC IP Address Manager (IPAM), so no two VPCs overlap. us-east-1 uses 10.144.0.0/16 and us-west-2 10.145.0.0/16. Two VPCs with the same range can never be joined by peering or a Transit Gateway; IPAM keeps that from happening as accounts and regions are added, so the Transit account's gateway joins every VPC without a clash.

We run one NAT gateway today, the cheapest option. To be fully safe against a zone failure we run one NAT gateway per zone, each private subnet going out through the gateway in its own zone. The network module has the switch.

AWS services are reached through VPC endpoints, so that traffic stays on the AWS network and skips the NAT gateway. S3 has one. Amazon Elastic Container Registry (ECR), AWS Security Token Service (STS), Secrets Manager, CloudWatch Logs, Systems Manager and Firehose get theirs. Each endpoint admits only our organization.

How a request reaches a service. The React web app and the Flask application programming interface (API) take two paths.

The web app: web.prod.innovate.example points at CloudFront, the AWS content delivery network. CloudFront checks the request with AWS WAF, the web application firewall, and serves the React files from an S3 bucket. Lambda@Edge, code CloudFront runs at its edge locations, adds security headers to every answer. Only CloudFront can read the bucket, through origin access control (OAC).

The API: api.prod.innovate.example points at the two static IP addresses of Global Accelerator. The accelerator takes the user onto the AWS network at the nearest edge location. It hands the connection, with the user's IP address, to the public Application Load Balancer (ALB) in us-east-1, or in us-west-2 when us-east-1 is down. The Database section explains why us-west-2 takes traffic only after a failover. The ALB checks the request with AWS WAF and ends Transport Layer Security (TLS), the encryption behind https addresses. It picks the service by host name: api. goes to the API, load. to the load-test service, and a name without a rule gets 403. The target groups hold the pods' own IP addresses, kept current by the AWS Load Balancer Controller, so the request goes from the ALB straight to a pod. The pod reaches the database through RDS Proxy.

Services that only other services call go behind the internal load balancer and are never published. Calls out to a third party leave through the NAT gateway, whose fixed address the third party can allowlist.

### Securing the network

We secure the network in layers. Only the 'edge' faces the internet, and it checks every request. Inside, each tier accepts traffic only from the tier in front of it. Organization rules keep it that way in every account. Two situations matter: someone on the internet attacking the application, and someone already inside, through a bug in the API for example, trying to go further or send data out.

The edge. CloudFront and Global Accelerator are the only ways in, and both come with AWS Shield Standard against common network floods. AWS WAF on CloudFront and on each public ALB checks every request.

In WAF: AWS managed rules stop known bad IP addresses, common web attacks and known bad inputs. Each IP address may send 2,000 requests in five minutes, then it is blocked. Trusted addresses, a partner or the office, skip that limit through an allowlist. WAF also stops SQL injection, database commands in Structured Query Language (SQL) smuggled into a request, and blocks the IP addresses on a blocklist we keep in Terraform.

Beyond the managed rules, sign-in and sign-up get much lower limits than reading data. The Anonymous IP list marks requests from Tor, virtual private network (VPN) services and hosting providers; we block them on sign-in and count them elsewhere. Bot Control stops scanners and scripts. Account takeover prevention stops sign-ins with stolen passwords. All WAF logs go to Log Archive.

Forged requests. Burp Suite and tools like it sit between the browser and our API. Someone catches a real request, changes it, say another user's number, a header the browser never sends or a field the form never sends, and replays it, once or thousands of times. WAF inspects the headers of every request before it reaches the API. We write those rules as regular expressions on the headers our app sends: Content-Type, Origin, Authorization, User-Agent. A request with anything in those headers that we do not expect is blocked, and as we learn new attacks we add more specific rules, each one its own rule. On top of that, the React app loads a small script from WAF, the AWS WAF JavaScript integration. The script proves to WAF that it runs in a real browser and gets a signed token, and the app sends that token with every API call. Bot Control challenges an address that keeps calling without a token and blocks a token used from many addresses at once. A replay tool has no browser, so it never gets a token. One careful person editing one request body in their own session still looks like a real user. The API stops that: on every request it checks who the user is, whether they may touch that record, and whether each input is what the endpoint expects.

Inside the VPC. Security groups, the firewall on each network interface, chain the tiers: the ALB takes web traffic, and Aurora takes port 5432 only from RDS Proxy. The proxy admits only the API pods, through EKS security groups for pods, and the nodes only what the cluster needs. Kubernetes network policies, enforced by the VPC CNI, block pod-to-pod traffic a service does not need. A network access control list (ACL) on the internal subnets admits the database port only from the private ranges. It is a second lock that does not depend on security groups.

Nodes and containers. CrowdStrike Falcon watches every node and container. The Falcon Operator runs the sensor as a privileged DaemonSet, one pod per node, so each node Karpenter launches is covered as it joins: process, file and network events, malware detection and prevention; its admission controller blocks pods and images that fail policy. One Terraform stack per cluster installs it, with the CrowdStrike credentials from Secrets Manager, and the observability EC2 nodes carry the same sensor in their Packer AMI. Security Tooling owns the Falcon tenant and feeds the detections to the SIEM. The sensor reports to CrowdStrike's cloud over the NAT gateway: security telemetry that leaves AWS, which the client signs off on.

Outbound. Private subnets reach the internet only through the NAT gateways. Before a pod can connect anywhere, it asks the VPC's Domain Name System (DNS) resolver for the address behind a name. Route 53 Resolver DNS Firewall sits on that resolver and refuses to answer for known malware and attacker domains, so a compromised pod cannot find its way home. If a compliance rule asks us to inspect outbound traffic, AWS Network Firewall goes between the private subnets and the NAT gateways and lets through only connections to domains we approve (optional).

Internal names. The database and RDS Proxy names live in a private DNS zone only the VPC can read, so nobody outside can look them up.

Rules above the accounts. The declarative policy that turns on IMDSv2, version 2 of the Instance Metadata Service, also turns on VPC Block Public Access in ingress-only mode. Internet traffic then enters only the subnets Terraform excludes, the public ones. A public IP address on anything else gets no traffic from the internet, whatever its route table says, and NAT gateways keep working.

Admin access. The cluster API is private, the bastion has no public address, and people reach both through Session Manager, part of AWS Systems Manager (SSM). Argo CD sits behind the internal load balancer and the company sign-in. The pipeline that applies the cluster components runs on a GitHub Actions runner inside the VPC. If that runner is down, cluster changes wait and running workloads carry on.

Encryption and logs. TLS ends at CloudFront and the ALBs. Because the data is sensitive, the ALB encrypts again to the pods. VPC Flow Logs record rejected connections, and all flow, WAF and load balancer logs go to Log Archive.

## Compute platform

### Kubernetes: deploying and managing the application

The application runs on EKS, one cluster per workload account and region, and Argo CD inside each cluster deploys it from Git. Argo CD is a GitOps controller: it reads the wanted state from a Git repository and makes the cluster match it. Terraform installs each cluster component in its own stack: Karpenter for nodes, the AWS Load Balancer Controller, external-dns for DNS records, metrics-server for scaling, a storage driver, the Falcon sensor and Argo CD. The same Terraform runs in each account with that account's values: one cluster in Dev, one in Staging, one per region in Prod. A control cluster in Shared Services with one master Argo CD is the option in the Observability section.

Upgrades. A Kubernetes upgrade goes to Dev, then Staging, then Prod, one minor version at a time, together with the EKS managed add-ons and the managed node group. Karpenter replaces its nodes by itself when a new node image comes out, a tenth of them at a time. Prod pins the Amazon Machine Image (AMI), the node's disk image, that passed Staging.

Access. People reach a cluster with their IAM Identity Center sign-in. An EKS access entry turns their permission set into Kubernetes rights: write in Dev, read-only in Staging and Prod. Nobody deploys to Staging or Prod with kubectl. The controllers and each service get AWS rights through EKS Pod Identity, which ties each one's Kubernetes service account to its own IAM role. Each service reads only its own secrets from Secrets Manager, mounted as files by the Secrets Store CSI driver, a Container Storage Interface (CSI) plugin.

### Node groups, scaling and resource allocation

A small managed node group runs the cluster's own controllers, and Karpenter launches every node the applications use. Pods scale with the load, nodes follow the pods, and every container states the processor (CPU) and memory it needs.

Node groups. The controllers run on an EKS managed node group of On-Demand Graviton nodes, two or more in different zones, with a taint, a mark that keeps off every pod that does not tolerate it, so only the controllers run there. Graviton is AWS's own Arm processor. Spot is spare capacity at a discount that AWS takes back with two minutes' warning; On-Demand is full price and stays. Karpenter has two NodePools, the sets of instance types it may launch, sixth generation or newer, Spot first.

In Prod every service keeps part of its replicas on On-Demand, so a wave of Spot reclaims never takes all of them. Savings Plans cover that steady part.

Scaling. Pods scale with the Horizontal Pod Autoscaler (HPA): the API on CPU, the load-test service on CPU and memory. An API that mostly waits on the database shows load late in CPU. So in Prod, KEDA (Kubernetes Event-driven Autoscaling) scales it on requests per pod, read from the ALB. Nodes follow the pods: Karpenter adds a node when pods cannot be placed, and removes empty or underused ones. Each pool has a CPU ceiling, so a runaway scale-out hits a wall before it hits the bill. Prod's ceilings come from load tests in Staging.

Growing from a few hundred users a day to millions needs no redesign: more pods, more nodes, more database readers. What to watch on the way: the pool ceilings, Spot capacity in the region, the database writer, and free addresses in the private subnets.

Resource allocation. Every service container states the CPU and memory it needs. Karpenter sizes nodes from that, and the HPA measures use against it. Each service has its own namespace, and a PodDisruptionBudget keeps all but one replica running while nodes are replaced. What is left is one workload crowding out the rest, and three Kubernetes objects stop it. A LimitRange gives a default size to containers that set none. A ResourceQuota caps each namespace. A PriorityClass keeps the API running ahead of batch work.

### Containerization: image building, registry, deployment

Every service is built once by GitHub Actions into one image for x86 and Graviton, kept in ECR under a tag that never changes. A commit to the GitOps repository deploys it, and the same image moves from Dev to Staging to Prod.

Continuous integration and delivery (CI/CD). Terraform writes each service repository's pipeline into it, so every service runs the same reviewed pipeline and a hand edit is overwritten on the next apply. A push or pull request to master runs the tests first, the API's against a real PostgreSQL. Each architecture then builds on its own native runner, x86 and arm64, and the API image must answer on its health endpoint before it is pushed. On master both images go to ECR under one multi-architecture tag. CodeQL, Snyk and zizmor scan the code, the dependencies and the workflows beside the build. The build pipelines reach AWS through GitHub OpenID Connect (OIDC): short-lived credentials, master only, no AWS key stored in GitHub. The web app's pipeline builds once and keeps the build in S3 for seven days. On every push to master it copies the build to the web bucket and clears the CloudFront cache.

Dependencies and code are built apart. Each service has a dependency image: the runtime and every library the service needs, built for both architectures by its own pipeline and pushed to ECR under its own tag. The service build pulls that image and adds the code on top, so a code change builds in seconds and pulls nothing from the package registries. A new library goes into the dependency image first; its pipeline builds and pushes a new tag, and the service pipeline moves to that tag in one reviewed commit. Nothing is installed during a service build, so a release runs with exactly the libraries in the tagged dependency image.

Versioning. An image tag is the git commit hash: one per architecture, one joint tag, no latest. ECR refuses to overwrite a tag, so a tag always means the same image. release-please, a release tool in GitHub Actions, opens a release pull request with a version number, vX.Y.Z, once commits are marked as features or fixes. After the release it adds the version as a second tag to the image already built. The Helm charts, the packages that describe each service's Kubernetes objects, are versioned by hand, and Argo CD reads them straight from Git.

GitOps. What runs in the cluster is written in the GitOps repository of-helm, and Argo CD pulls it from there. Terraform creates one Argo CD Application per service and region, Argo CD's record of which chart goes to which cluster, and points it at the chart on master. Argo CD applies changes on its own, removes what was deleted from Git and reverts hand changes in the cluster. Both production regions read the same values file, so one commit deploys both; Dev and Staging have their own, so a commit can go to Dev without touching Prod.

The deployer. Developers should not have to think about Argo CD. They deploy with our own deployer, of-launch: sign in with the company login, pick the environment, the service and a build, click deploy. The deployer commits that build's tag to of-helm and asks Argo CD to sync. The commit is the audit record, and the deployer shows who deployed which build where and when. Rolling back is deploying the previous build. Argo CD's own interface stays open, read-only, for anyone who wants to watch a sync.

Deploy rules. Dev deploys every merge to master by itself. Staging and Prod deploy through the deployer, Prod takes only a build that has run in Staging, and a Prod deploy needs a second person's approval. That keeps the rule from the account structure: every change to production is a commit plus a pipeline run, and nobody has write access to Prod.

of-launch is a Flask app. It signs people in with the company login, knows one Argo CD per cluster, reads the result of each deploy back from Argo CD, keeps the deploy history, and enforces the deploy rules above.

Registry. One ECR registry sits in Shared Services in us-east-1. It scans each image on push, refuses tag overwrites, and copies the images to us-west-2, so the second region can pull while us-east-1 is down. Workload accounts pull through ECR VPC endpoints.

Supply chain. The risk is a vulnerable dependency or a tampered image reaching Prod. A pull request merges only with a review and green tests and scans. Every build keeps its software bill of materials (SBOM), the list of packages in the image, and its provenance record, how and from what it was built. Amazon Inspector rescans stored images when a new vulnerability is published. Images are signed at build, and an admission policy checks the signature before a pod may start.

Infrastructure. All of the infrastructure is code, and the code is Terraform. Infrastructure changes have their own pipeline: it plans with a read-only role and applies with an admin role. Every pull request gets a plan, a reviewer approves, and the merge applies that plan, in each account. Today GitHub Actions runs that pipeline. The target is a tool made for running Terraform, and the budget picks which one: Terraform Cloud or Spacelift, paid services that run every plan and apply on their side and keep the run history, the approvals and, if we want, the state; or Atlantis, free, hosted by us on a runner in the VPC, with the state staying in S3. All three do the same job here: a plan on every pull request, an apply on merge, one run per stack at a time. The tool we run also takes a webhook from the failover function and does the regional swap as a Terraform run; the Database section has the reason.

Modules. Today the modules sit in this repository under modules/, each version as its own folder, and a stack picks one by path. There are two ways to grow this. Option A: each module gets its own repository and is versioned there with git tags, and a stack points at the repository and a tag. Option B, with fewer repositories: one repository holds every module, with a git tag per module version, and a stack points at that tag.

## Database

### PostgreSQL service and why

We use Amazon Aurora PostgreSQL as a global database: a writer and a reader in us-east-1, and a read-only copy in us-west-2. The application is written for PostgreSQL, so we keep PostgreSQL and let AWS run it.

Why Aurora:

Aurora keeps six copies of the data across three zones, so losing a zone loses no data.

When the writer fails, a reader in another zone takes over, usually in under a minute.

A global database copies every change to the second region, typically within a second. It promotes that copy in minutes, as one managed step that keeps the database's address. Amazon Relational Database Service (RDS) for PostgreSQL gets there only by promoting a replica and pointing every client at its new address.

Readers share the writer's storage, so more read capacity for millions of users means adding readers, up to 15, without copying data.

Running PostgreSQL ourselves on EKS would leave backups, failover, patching and encryption to us, for the most sensitive data we hold.

RDS Proxy sits in front of the database. It pools connections, so hundreds of API pods do not run the database out of them. It also keeps the application's connections open while a reader is promoted.

Capacity. The writer and the readers run on provisioned Graviton instances, db.r6g.large to start, the smallest class a global database accepts. Growth is more readers and a larger class for the writer when it runs out of CPU; a class change restarts one instance at a time, and RDS Proxy keeps the connections. Reserved instances cover the steady part of the bill.

Encryption and credentials. The data is encrypted with a customer managed key (CMK) of the Prod account, which the copy to the Backup account's vault requires; an AWS managed key cannot be shared across accounts. The password sits in Secrets Manager and reaches the pods through the Secrets Store CSI driver. Terraform writes it without keeping it in its state. AWS Identity and Access Management (IAM) authentication between the pods and RDS Proxy then takes the shared password out of the application.

### Backups, high availability, disaster recovery

Aurora backs up continuously, a reader in a second zone covers a failed writer, the copy in us-west-2 covers a lost region, and the Backup account covers a lost or compromised Prod account.

Backups. Aurora's continuous backup restores the database to any point in the retention window: 35 days in Prod, the most Aurora allows. An organization backup policy takes a daily snapshot with AWS Backup and copies it to a logically air-gapped vault in the Backup account, in us-west-2. That vault is always locked: nobody, an administrator of the Backup account included, can delete a copy before it expires. AWS Backup restore testing restores a recent copy on a schedule and checks it, so we know a backup works before we need it. Deletion protection is on, and a final snapshot is taken before any delete.

High availability. In us-east-1 the cluster runs a writer and a reader in different zones, and us-west-2 keeps at least one reader. When the writer fails, Aurora promotes the reader, usually in under a minute, and RDS Proxy moves the connections.

Disaster recovery. us-west-2 holds the global database's secondary cluster, a copy that trails by about a second and only reads until it is promoted. Because that copy cannot take writes, us-west-2 waits at traffic dial 0, the share of new connections the accelerator sends there. Aurora never moves the writer to another region by itself. A planned switchover loses nothing; an unplanned failover can lose the last seconds of writes. The failover function in us-west-2 sets the us-east-1 dial to 0, promotes us-west-2, then sets the us-west-2 dial to 100. The trigger is a CloudWatch alarm in us-west-2 on the accelerator's own health checks: when the accelerator sees no healthy endpoint in us-east-1 for three minutes in a row, EventBridge, the AWS event bus, hands the alarm to the function. The alarm lives in us-west-2 because the accelerator publishes its metrics there, so it still fires when us-east-1 is down. A switch in the function's settings decides what it does on that alarm: report only, or promote. It starts at report only; once drills show the alarm fires only for a real outage, the switch moves to promote and the failover runs by itself. If losing the last seconds of writes is not acceptable, the rds.global_db_rpo setting makes the writer wait while the copy lags too far behind. That trades write availability for a known maximum loss.

Failover and Terraform. Today GitHub Actions runs the infrastructure Terraform, and the failover function does the swap on its own, straight against the AWS API: dial us-east-1 down, promote the database in us-west-2, dial us-west-2 up.

In the future we move the Terraform runs to a tool built for it, Terraform Cloud, Spacelift or a self-hosted Atlantis, depending on the budget, and give it a webhook, a URL that starts a run when it is called. The function then calls that URL instead of the AWS API, with us-west-2 as the new active region, and the run does the same three steps through Terraform. The state changes with the apply, so nothing drifts, and the failover sits in the run history with its plan and its log, like any other change.

| What fails | What takes over | Data lost (recovery point objective, RPO) | Back in (recovery time objective, RTO) |
| --- | --- | --- | --- |
| The writer, or its zone | The reader in another zone | None | Usually under a minute |
| The us-east-1 region | The us-west-2 copy, promoted | The last seconds of writes | Minutes after the failover starts |
| A bad change, such as a dropped table | A point-in-time restore into a new cluster, from which the lost data is copied back | None, if we know when it happened | As long as the restore takes |
| The Prod account, taken over or encrypted | A restore from the Backup account's vault | Everything since the last daily copy | As long as the restore takes |

Where the design is weakest:

Traffic moves by itself, the database does not. The accelerator sends users to us-west-2 as soon as the us-east-1 ALB looks unhealthy, whatever the dial says, and writes fail there until the copy is promoted.

During a failover Aurora tries to stop writes in the old region but cannot promise it. That is why the function takes us-east-1 out of traffic first.

A bad change reaches every copy within seconds. Only the backups undo it.

## Observability

Innovate Inc. keeps its log data away from outside providers, so the observability stack is self-hosted: the Elastic Stack, Elasticsearch, Logstash and Kibana, in the Shared Services account, under an Elastic Enterprise subscription, a license priced per node rather than per gigabyte. Every log line and every metric lands in a bucket we own before the stack sees it, so the data outlives any tool we pick.

Other viable options: Dynatrace, Datadog, Logzio.

### Network and placement

Network. Telemetry never leaves the AWS network. A Transit account, the ninth, holds the transit network: a Transit Gateway in each region, the two peered, and the transit VPC. The Dev, Staging and Prod VPCs and the Shared Services VPC attach to the gateway, and a pod sends to a name in the private zone, which every attached VPC resolves, and the traffic crosses the gateway to the Shared Services VPC. Traces, profiles and metrics go this way. Logs do not: Fluent Bit hands them to Firehose through the VPC endpoint in its own VPC, Firehose writes them to S3, and Logstash reads S3 through the endpoint in the Shared Services VPC. Anything that crosses an account boundary does it with a role that carries the policy for it.

Placement. The stack runs in us-east-1, next to the registry. Packer builds a golden AMI for each node type, Terraform launches it and Ansible applies the configuration, so adding capacity is adding a node to the pool. Elasticsearch runs on three nodes, one per zone, all three master-eligible so that losing one leaves a majority and the cluster keeps working; the first node also runs Kibana, the other two also run Logstash, and a new data node takes its share of the shards by itself. Two APM Server nodes take the traces, one node runs Heartbeat, one runs the profiling collector and symbolizer, one machine learning node runs the anomaly jobs, a monitoring node runs Prometheus with Thanos beside it, and Grafana has its own node. Kibana and Grafana sit behind the internal ALB, reachable only from inside the network, over the VPN.

### What we collect and where it goes

Logs. Fluent Bit runs as a DaemonSet, one pod per node, reads every container's output from the node's log directory and attaches the pod, namespace and labels. Filebeat, the Elastic shipper, has no Kinesis output, which is why the shipper is Fluent Bit. It writes to Amazon Data Firehose, and Firehose writes a compressed file to the logs bucket of its region in Log Archive every 5 MiB or 60 seconds, whichever comes first, with a role the bucket policy admits. Those buckets are the copy we own. Each one replicates to the other region, so both regions hold every log, and both carry the same lifecycle rule, because replication copies objects and not rules: files move to Glacier after 90 days and are deleted after a year. Logstash pulls the files under the node's role with Elastic's S3 input, which remembers the date of the last file it took, parses the JSON, sets the region, environment and service from the Kubernetes fields, and writes each line into a data stream named logs-<region>-<environment>-<service>. A data stream is Elasticsearch's container for append-only time series: it rolls to a new index on size or age, and its lifecycle policy moves old indices to the warm tier and deletes them after 90 days. Each Firehose stream writes under its own prefix and each Logstash node owns a set of prefixes, so no file is read twice. When two readers stop being enough, S3 event notifications into an SQS queue and Filebeat's aws-s3 input let any number of readers share one queue.

Traces. APM Server, Elastic's trace receiver, takes OpenTelemetry (OTLP) natively, gRPC and HTTP on one port. The tracing library runs inside the application process: the Flask API gets Elastic's OpenTelemetry Python SDK injected at pod start by the OpenTelemetry Operator, from one annotation on the Deployment and no code change, and a compiled service builds it into the binary. The library sends spans across the Transit Gateway straight to the APM nodes, by their name in the private zone, which resolves to both; they write to Elasticsearch, and Kibana's APM app shows each service's latency and errors and the path of one request through the API and the database. Traces keep no copy in S3: they are for diagnosis, the logs are the evidence.

Real user monitoring. The Elastic RUM agent runs in the React app and sends page load times, JavaScript errors, route changes, user interactions and Core Web Vitals to APM Server, so Kibana shows what the users see, not only what the API does. The browser posts to a path on the web app's own CloudFront distribution; CloudFront forwards it to the public ALB with the header only it adds, WAF lets only that through, and the ALB hands it to the APM nodes. CI uploads each build's source maps, so a minified stack trace reads as code.

Metrics. Alloy, Grafana's collector, runs as a DaemonSet on each cluster and scrapes the kubelet, cAdvisor, kube-state-metrics and any exporter we add; a new exporter is one more scrape target, and the cluster ships it. Alloy sends the samples across the Transit Gateway to Prometheus on the monitoring node, and metrics-server stays in each cluster for the autoscalers. Prometheus keeps 15 days on disk. Thanos uploads every block to the metrics bucket in Log Archive and reads it back for Grafana through its store gateway, so a lost cluster or a rebuilt node loses no history, and its compactor downsamples old blocks and applies the retention: raw samples for 90 days, five-minute samples for a year, hourly for five years. The metrics bucket replicates to the second region like the logs buckets, and the replica, which Thanos never reads, moves to Glacier after 90 days.

Uptime. Heartbeat calls every endpoint we expose every minute, from the accelerator and CloudFront down to the API's health path and Kibana itself, and writes the result to Elasticsearch. A Kibana rule emails when a check fails three times in a row.

Anomalies. The machine learning node runs Elastic's anomaly detection over the log data streams and the traces: log rate and error rate per service, API latency. A pattern the fixed rules did not foresee becomes an alert through the same connectors.

Profiles. Universal Profiling runs an eBPF agent as a DaemonSet on every node; eBPF programs run inside the Linux kernel and sample every process without touching its image. The samples cross the Transit Gateway to the collector, the symbolizer turns addresses into function names, and Kibana shows where the CPU goes across the fleet, the API included.

Asking in plain words. A custom MCP server, Model Context Protocol, the interface AI tools use to call other systems, runs next to Claude Code on an engineer's machine and reaches Elasticsearch from inside the network with a read-only account. Its tools search logs, search traces and sum up APM statistics per service; a second one reads Kibana's security alerts and detection rules. The SRE and security teams ask Claude, or any other AI tool, in plain words: which service logged this error first, what changed before the latency rose.

| Signal | Collected by | Travels | Kept in | Copy we own |
| --- | --- | --- | --- | --- |
| Logs | Fluent Bit on each node | Firehose to S3, Logstash pulls | Elasticsearch data streams, 90 days | S3 in Log Archive, replicated to the second region, one year |
| Traces | OpenTelemetry SDK in the pod | Transit Gateway to APM Server | Elasticsearch, 30 days | None |
| Browser | RUM agent in the web app | CloudFront, the public ALB and WAF to APM Server | Elasticsearch, 30 days | None |
| Metrics | Alloy on each cluster | Transit Gateway to Prometheus, Thanos to S3 | Prometheus 15 days, the bucket after that | S3 in Log Archive, replicated to the second region |
| Uptime | Heartbeat | Straight to Elasticsearch | Elasticsearch | None |
| Profiles | eBPF agent on each node | Transit Gateway to the collector | Elasticsearch | None |

When a Logstash node is down, its prefixes wait in the bucket. That part of the view lags until it is back; nothing is lost.

### Analytics

PostHog does product analytics: it shows what users do in the web app. It runs in its own account, Analytics, under the Prod OU, because what it holds is user data and Shared Services holds none.

Its snippet in the React app records page views, clicks, the events we name and session replays. The browser sends them to a path on the web app's CloudFront distribution, which forwards them to the Analytics account's public ALB behind WAF; nothing passes through the API or the clusters. From that data the team builds funnels and retention, and ships features behind feature flags and A/B experiments. The team opens PostHog over the VPN.

PostHog is a set of services spread across the Analytics account: Postgres on Aurora PostgreSQL, Kafka on Amazon MSK, Redis on ElastiCache, session recordings in S3, ClickHouse on its own nodes, and PostHog's own services on EC2 nodes from a Packer golden AMI or on an EKS cluster. Each part grows on its own as traffic grows, and we run and upgrade it ourselves. Events, people and recordings stay inside the account, backed up daily by AWS Backup.

PostHog tracks a user only after they agree in the cookie banner, session replays mask form inputs and personal fields, and a user's deletion request is carried out in PostHog.


## Improvements

In the order we would do them: first the two regions, then what makes them safe for sensitive data and steady under load, then the move into the organization.

Second region traffic. us-west-2 at dial 0 until a failover, because it has no database it can write to.

Database. db.r6g.large instances, the class a global database accepts, a reader in a second zone, 35 days of backups, deletion protection, a final snapshot and a customer managed key. Then the global database with its us-west-2 copy.

Failover. A CloudWatch alarm in us-west-2 on the accelerator's health checks of us-east-1 starts the function; it reports only until drills pass, then it promotes. Terraform leaves the dials alone once they exist.

NAT gateways. One per zone.

Address ranges. One per VPC from IPAM.

Security groups. RDS Proxy admits only the API pods, and the system nodes only what the cluster needs.

Database password. Never kept in the Terraform state. (state rm)

Internal names. A private DNS zone for the database names.

VPC endpoints. ECR, STS, Secrets Manager, CloudWatch Logs, Systems Manager and Firehose.

Public exposure. The bastion and Argo CD on private addresses, behind Session Manager and the company sign-in. A private cluster API, an ALB that admits only the accelerator, and VPC Block Public Access.

Web bucket. Origin access control, CloudFront access logs, and Content-Security-Policy and X-Frame-Options headers from Lambda@Edge.

Controllers. A tainted On-Demand Graviton node group for the controllers.

Scaling. KEDA on in Prod.

Release path. of-launch as the way to deploy, with values per environment and region in of-helm. The release-please version file belongs to the repository, not to Terraform. ECR keeps release tags when it cleans up.

Terraform pipeline. A real approval with required reviewers, an apply of the reviewed plan, and state locking on the S3 backend, so two applies of one stack cannot overlap.

Cluster hardening. Control plane logging, a customer managed key for Kubernetes Secrets, and multi-factor authentication (MFA) on the developers' role until Identity Center replaces it. That role and the chart pipeline's role get edit rights only in the namespaces of the services they deploy. The Falcon sensor on every node and its admission controller in front of every deploy.

Observability. The Elastic Stack, Prometheus, Thanos and Grafana in Shared Services, PostHog in the Analytics account, Fluent Bit and Alloy on every cluster, the logs and metrics buckets in Log Archive, and the Transit account that joins the VPCs.

The organization. Control Tower creates the landing zone and the accounts, and Identity Center takes over sign-in. Each stack moves to its account: the registry, the parent DNS zone and the Terraform state to Shared Services; the backup bucket to Backup; the Transit Gateways to Transit; network, cluster, database and edge to Dev, Staging and Prod, with both production regions inside Prod.

EKS Org cluster, instead of having argocd per EKS, create a separate control management cluster.
Instead of EC2 nodes, a shared EKS control cluster in the Shared Services account runs all of these services: the Elastic Stack through ECK, Elastic's Kubernetes operator, which handles the node sets and rolling restarts; Prometheus, Thanos and Grafana as charts; and the master Argo CD, which deploys to every workload cluster over the Transit Gateway. The workload clusters then carry only the add-ons and controllers the application depends on, Karpenter, the load balancer controller, external-dns, metrics-server, the storage driver, Fluent Bit, Alloy, the OpenTelemetry Operator and the profiling agent, while every system service lives in one place, scaled by Karpenter like any other workload. The control cluster then sits under every deploy and every dashboard: it gets the same care as Prod, and losing it stops deploys and views while the workloads keep running.
## Glossary

Abbreviations and names used in this document, with what each means here.

| Term | Stands for and what it is here |
| --- | --- |
| Access entry | EKS's list of which IAM roles may call the cluster API and with which Kubernetes rights |
| ACL | Access control list; a network ACL filters a subnet's traffic by address range and port |
| Add-on | A cluster component EKS installs and upgrades, such as pod networking, cluster DNS and the Pod Identity agent |
| ALB | Application Load Balancer; the public ALB behind the accelerator, and the internal ALB in the private subnets |
| Alloy | Grafana's collector; a DaemonSet in each cluster that scrapes metrics and sends them to Prometheus by remote write |
| AMI | Amazon Machine Image, the disk image a node boots from |
| Anonymous IP list | AWS WAF managed rule group that marks requests from Tor, VPN services and hosting providers |
| Ansible | Configuration tool; applies each observability node's setup after Terraform launches it |
| API | Application programming interface; here the Flask REST API the web app calls |
| APM Server | Elastic's trace receiver; takes OpenTelemetry data from the services and writes it to Elasticsearch |
| Argo CD | GitOps controller inside the cluster; pulls the of-helm repository and applies what it finds |
| Argo CD Application | Argo CD's record of which chart and values go to which cluster |
| AWS | Amazon Web Services |
| AZ | Availability Zone, separate data centers within one region; Multi-AZ means copies in two or more |
| Baseline | The Terraform module applied to every new account: default VPC removed, encryption defaults, OIDC provider, deploy role, budget, tags |
| Bastion | The one server in the VPC an operator reaches through Session Manager to get at private resources |
| Bot Control | AWS WAF managed rule group for bots; its targeted level checks each request for a token only a real browser running the app gets |
| BreakGlass | The time-boxed, paged permission set for writes in Staging, Prod and Backup |
| Burp Suite | Proxy tool that catches, edits and replays web requests, used for security testing and for attacks |
| cAdvisor, kube-state-metrics | Container resource metrics from the kubelet, and metrics about Kubernetes objects such as pods and deployments |
| CD | Continuous delivery; here Argo CD pulling the GitOps repository into the cluster |
| CDC | Change data capture; streams each insert, update and delete out of the database as it happens, instead of copying whole tables |
| CI | Continuous integration; the GitHub Actions workflows that test, build, push images and run Terraform |
| CLI | Command-line interface; here the `aws` command |
| ClickHouse | Column database built for fast queries over many events; PostHog keeps its events in it |
| CloudFront | AWS content delivery network; serves the web app from S3 with WAF in front |
| CloudWatch | AWS monitoring service: logs, metrics and alarms |
| CMK | Customer managed key, a KMS key the account creates and controls, unlike an AWS managed key |
| CNI | Container Network Interface; the VPC CNI gives every pod an IP address from the VPC and enforces network policies |
| CodeQL, Snyk, zizmor | Scanners in CI: code analysis, known vulnerabilities in code and dependencies, mistakes in GitHub Actions workflows |
| Control Tower | AWS service that creates and governs the organization: landing zone, OUs, account vending, organization policies |
| CPU | Processor; Karpenter NodePools cap the total CPU they may launch |
| CSI | Container Storage Interface; the Secrets Store CSI driver mounts Secrets Manager values into pods as files |
| Data stream | Elasticsearch's container for append-only time series; rolls to a new index on size or age and ages out by its lifecycle policy |
| Declarative policy | Organization policy that sets a service's configuration, such as IMDSv2 or VPC Block Public Access, in every account |
| Delegated administrator | The member account that runs an organization-wide service (GuardDuty, Security Hub, Identity Center) instead of Management |
| Dependency image | Base image with the runtime and every library a service needs, built and tagged by its own pipeline; the service build adds only the code |
| DNS | Domain Name System; Route 53 holds the zones |
| DNS Firewall | Route 53 Resolver DNS Firewall; refuses DNS lookups of listed domains, such as known malware sites and the servers attackers use to steer compromised machines |
| DR | Disaster recovery; the second region and the Backup account |
| eBPF | Programs that run inside the Linux kernel; the profiling agent uses them to sample every process without touching its image |
| ECK | Elastic Cloud on Kubernetes, Elastic's operator that runs the Elastic Stack on a Kubernetes cluster |
| ECR | Elastic Container Registry; holds the images |
| Edge location | One of AWS's sites close to users, where CloudFront and Global Accelerator take traffic in |
| EKS | Elastic Kubernetes Service, the managed Kubernetes cluster |
| Elastic Stack | Elasticsearch, the search and storage engine; Logstash, the pipeline that reads, parses and writes; Kibana, the web interface; APM Server, Heartbeat and Universal Profiling come with it |
| ElastiCache | AWS managed Redis, the in-memory store PostHog uses |
| ETL, ELT | Extract, transform, load, or extract, load, transform: a pipeline that copies data from one store to another, cleaning or reshaping it before or after the copy |
| EventBridge | AWS event bus; here it carries the alarm's state change to the regional failover function |
| external-dns | Controller that writes Route 53 records for Kubernetes services |
| Falcon | CrowdStrike Falcon; the sensor on every node and container, its admission controller, and the tenant in Security Tooling |
| FIDO2 | Open standard for hardware security keys used as the second sign-in factor |
| Firehose | Amazon Data Firehose; takes a stream of records and writes them to S3 in files, by size or time |
| Flow Logs | VPC records of connections |
| Fluent Bit | Log shipper; a DaemonSet that reads every container's output on its node and sends it to Firehose |
| GitOps | Cluster state declared in a Git repository and pulled by a controller, not pushed by a pipeline |
| Glacier | S3 storage classes for data kept but rarely read; cheaper, with hours to restore |
| Global Accelerator | Two static anycast IP addresses in front of each region's public ALB, with health-based failover between regions |
| Grafana | Dashboards over the metrics; reads them through Thanos |
| Graviton | AWS's Arm processors (arm64); x86 means Intel and AMD |
| GuardDuty, Security Hub, Inspector, Macie, Config, Access Analyzer | AWS detective services: threat findings, finding aggregation and checks, vulnerability scans, sensitive-data discovery, configuration history, unintended-access analysis |
| Heartbeat | Elastic's uptime checker; calls each endpoint on a schedule and records the result |
| Helm, chart | Kubernetes package manager; a chart is a templated set of manifests driven by a values file |
| HPA | Horizontal Pod Autoscaler; adds or removes pods on CPU or memory from metrics-server |
| IAM | Identity and Access Management: roles and policies |
| Identity Center | IAM Identity Center, formerly AWS SSO; one sign-in through the company directory, then a permission set per account |
| IMDSv2 | Instance Metadata Service version 2, the token-protected way a node reads its metadata and credentials |
| Internet gateway | The VPC's connection to the internet; only the public subnets route to it |
| IP address | Internet Protocol address; a public one can be reached from the internet |
| IPAM | Amazon VPC IP Address Manager; hands out address ranges from one pool so no two VPCs overlap |
| Karpenter | Node autoscaler; launches nodes for pods that cannot be placed and removes empty or underused ones |
| KEDA | Kubernetes Event-driven Autoscaling; scales pods on outside metrics such as ALB requests per pod |
| KMS | Key Management Service, the encryption keys |
| kubectl | The Kubernetes command-line tool |
| Lambda | AWS Lambda, functions that run without a server we manage |
| Lambda@Edge | Code CloudFront runs at its edge locations; here it guards the web bucket and adds security headers |
| Landing zone | Control Tower's starting setup: the organization, the Security OU accounts, logging and the organization policies |
| LimitRange, ResourceQuota | Kubernetes objects: a default size for containers that set none, and a ceiling for a whole namespace |
| Logically air-gapped vault | AWS Backup vault that is always locked in compliance mode; nobody can delete a copy before it expires |
| Managed node group | EKS-managed set of nodes; here the system nodes the controllers run on |
| MCP | Model Context Protocol; the interface AI tools use to call other systems, here a server that lets Claude search the logs and traces |
| metrics-server | Collects pod and node CPU and memory for the HPAs and `kubectl top` |
| MFA | Multi-factor authentication |
| MSK | Amazon Managed Streaming for Apache Kafka; the managed Kafka queue PostHog's events pass through |
| NAT gateway | Network address translation gateway; lets private subnets reach the internet outbound while staying unreachable inbound |
| Network policy | Kubernetes rule for which pods may talk to which |
| NodePool | Karpenter object: the instance types, capacity types, architecture, limits and taint a set of nodes may use |
| OAC | Origin access control; lets only the CloudFront distribution read the S3 bucket |
| Object Lock | S3 setting that blocks deleting or changing objects for a retention period |
| OIDC | OpenID Connect; GitHub Actions gets AWS credentials with a signed token instead of stored keys |
| On-Demand, Spot | Server pricing: On-Demand is full price and stays; Spot is spare capacity at a discount that AWS takes back with two minutes' warning |
| OpenTelemetry | Open standard and SDKs for traces, metrics and logs; OTLP is its wire protocol, and its Operator injects the SDK into pods |
| OU | Organizational unit, a folder of accounts in an AWS Organization that policies attach to |
| Packer | Builds the golden AMI each observability node type boots from |
| PCI, SOC 2, HIPAA | Compliance regimes: card payments, service-organization controls, US health data |
| Permission set | Identity Center's role template; becomes a role in each account it is assigned to |
| Pod Identity | EKS Pod Identity; binds a Kubernetes service account to an IAM role through the Pod Identity agent |
| PodDisruptionBudget | How many pods of a service may be down while nodes drain; here all but one stay up |
| PostHog | Open-source product analytics: events, funnels, retention, session replay, feature flags and experiments; self-hosted in the Analytics account |
| PriorityClass | Kubernetes object that decides which pods keep running when capacity is short |
| Prometheus | Metrics database; receives what Alloy ships and keeps 15 days on disk |
| RDS Proxy | Managed connection pool between the application and the database; keeps connections open during a failover |
| RDS, Aurora | Relational Database Service; Aurora is its PostgreSQL-compatible engine, a global database replicates to another region |
| release-please | Release tool in GitHub Actions that opens release pull requests and tags semantic versions |
| Resource Access Manager | AWS service that shares resources such as a Transit Gateway across accounts |
| Resource control policy | Organization policy on the resource side (buckets, keys, secrets, queues, role credentials) limiting who may call it |
| REST | Representational state transfer; the request style of the Flask API |
| Route 53 | AWS DNS; the hosted zones and their records |
| RPO, RTO | Recovery point objective, the data a failover may lose; recovery time objective, how long until service is back |
| RUM | Real user monitoring; the Elastic agent in the browser that reports what users experience to APM Server |
| S3 | Simple Storage Service, the buckets |
| Savings Plans | AWS discount for committing to a steady amount of compute per hour |
| SBOM | Software bill of materials, the list of packages in an image |
| Secrets Manager | AWS secret store; the Secrets Store CSI driver mounts its values into pods |
| Security group | Stateful firewall on a server, load balancer or pod network interface |
| Service control policy | Organization-wide rule that caps what anyone in an account may do, inherited down the tree, never applied to Management |
| Shield Standard | AWS protection against common network floods, included at no extra cost on CloudFront and Global Accelerator |
| SIEM | Security information and event management, the tool that collects and correlates security logs |
| SOC | Security operations center |
| SQL | Structured Query Language; SQL injection smuggles database commands into a request |
| SQS | Simple Queue Service; here the queue S3 would notify when a new log file lands |
| SSM | Systems Manager; Session Manager opens a shell on the bastion with no inbound port open |
| SSO | Single sign-on |
| Stack, module, rollout | Terraform layout: a stack is one root with its own state, a module a building block under `modules/`, the rollout the order in which a folder's stacks are applied |
| STS | Security Token Service; issues the short-lived credentials behind every assumed role |
| Taint | Node mark that keeps away pods that do not tolerate it; the Graviton pool is opt-in through its taint |
| Target group | The set of targets, here pod IP addresses, an ALB rule sends traffic to |
| Terraform Cloud, Spacelift, Atlantis | Tools that run Terraform from pull requests: Terraform Cloud (now HCP Terraform) and Spacelift are paid services, Atlantis is free and self-hosted; one of them runs the infrastructure pipeline and takes the failover webhook |
| Thanos | Sits beside Prometheus: uploads its blocks to S3, reads them back for Grafana, compacts and downsamples them |
| TLS | Transport Layer Security, the encryption behind https addresses |
| Traffic dial | Global Accelerator's share of new connections sent to one region |
| Transit Gateway | Hub that routes between VPCs; one per region in the Transit account, carries traces, metrics and profiles from the clusters to the Shared Services VPC |
| Universal Profiling | Elastic's continuous profiler; an eBPF agent on each node samples every process, and Kibana shows where the CPU goes |
| VPC | Virtual Private Cloud, the private network with its subnets |
| VPC Block Public Access | VPC setting that blocks internet traffic to every subnet not excluded; here only the public subnets are excluded |
| VPC endpoint | Private path from the VPC to an AWS service without the internet; an interface endpoint is a network interface in the VPC, a gateway endpoint a route-table entry |
| VPN | Virtual private network |
| WAF | Web Application Firewall; rule sets on CloudFront and the public ALB |
| Webhook | A web request one system sends to start work in another; here the failover function's call to the Terraform pipeline tool |
