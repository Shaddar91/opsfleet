# Innovate Inc. cloud architecture

## Summary
Innovate Inc. runs a React single-page app, a Flask REST API and a PostgreSQL database, and we put it on AWS. The design is one AWS Organization of eight accounts, so that environments, evidence, backups and shared tooling sit behind hard boundaries. The application runs on EKS, with Karpenter adding and removing x86 and Graviton nodes on Spot and On-Demand capacity. The database is Aurora PostgreSQL  replicated to a second region. People sign in once through IAM Identity Center, and every change to production is a commit plus a pipeline run. Today everything is built by the Terraform in terraform/ inside one AWS account; the organization, the identity layer and the detection services are the proposal.

## Where we are and where we want to be

Today the Terraform in terraform/ builds the system in one AWS account and two regions: production in us-east-1 and a copy of it in us-west-2, with Global Accelerator in front to send each user to the nearest healthy region. The database runs in us-east-1. The code can turn it into an Aurora global database with a read-only copy in us-west-2, and a Lambda function in us-west-2, started by hand, takes us-east-1 out of traffic and promotes that copy. That is disaster recovery (DR) at the level of regions: when one region fails, the other carries on.

The target takes the same idea one level up, to accounts. A second region protects us from a region going down. Separate accounts protect us from what goes wrong inside one account: a leaked pipeline key, a deleted database, a load test that uses up a quota, a person with more access than the job needs. Each of those stays inside the account where it happened. So the one account becomes an AWS Organization of eight accounts in organizational units (OUs), shown in the next section, and both regions stay together inside the Prod account. The Backup account does the same for the data: its copies survive even someone taking over Prod, which neither the second region nor a standby database in another zone can do.

Built marks what the Terraform in this repository creates today. Not built yet marks what is proposed.

## Cloud environment structure
Innovate Inc. needs an AWS Organization with organizational units (OUs). The brief asks for a secure, scalable and cost-effective setup that can grow to millions of users, so we split the system into separate AWS accounts and group them in OUs. If a compliance requirement shows up later (SOC 2, HIPAA, PCI), the structure already fits and needs little or no change.

An account is the hard boundary in AWS. IAM, blast radius, quotas and billing all stop at the account; Accounts cannot be merged or split later without rebuilding what is inside, so we create the full structure now, and Terraform creates and baselines every account.

The organizational units:

Root
  Management: owns the organization, nothing else runs here
  Security OU
    Log Archive: all logs and audit trails, nobody logs in here
    Security Tooling: the security team's account, the SIEM, alerting
  Infrastructure OU
    Shared Services: container registry, parent DNS zone, Terraform state, CI roles, Grafana
    Backup: the backup vault, cut off from Prod
  Workloads OU
    NonProd OU
      Dev
      Staging
    Prod OU
      Prod: the users and their data

Eight accounts in five OUs.

Management only owns the organization. The organization rules below do not apply to it, so nothing runs in it. Log Archive holds the evidence and has to survive a break-in anywhere else. Security Tooling is where the security team works; it is a separate account from Log Archive so the account with the strongest cross-account roles does not also hold the logs. Shared Services has the tooling every environment uses and holds no user data. Backup is separate from Shared Services so a compromised pipeline cannot reach the backups. Dev is a real deployment of the product with synthetic data. Staging is the release gate, with the same IAM setup as Prod and its own quotas, so load tests do not hit Dev. Prod serves the users and holds their data; the second region is in this account too. Two optional accounts can come later. A Data Engineering account, in its own Data OU under Workloads, receives production data through CDC, ETL or ELT pipelines that strip or mask the sensitive fields, so the data team works without touching regulated data. A Transit account under the Infrastructure OU holds a Transit Gateway shared through AWS Resource Access Manager, for the day VPCs in different accounts must reach each other; nothing needs that today. Three OUs are reserved and not created on day one: Sandbox for per-engineer accounts with a hard budget and no path to Prod, PolicyStaging where a new rule is attached first, Suspended for closed accounts under a deny-all rule for 90 days.

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

Log Archive and Security Tooling are two accounts, and that is on purpose. Log Archive holds what nobody reads daily: CloudTrail, Config history, VPC flow logs, load balancer and CloudFront access logs, Security Lake. Only AWS services write to it, nobody logs in day to day, and a SecurityAnalyst gets read-only access during an investigation. Security Tooling holds the SIEM, the admin of the security services (GuardDuty, Security Hub, Inspector, Macie, Config, IAM Access Analyzer) and the alert routing, and the security team works there. Metrics, traces and application logs, the things on-call reads daily, stay in each workload account, and Grafana in Shared Services reads them across accounts.

###### Why this split: isolation, billing, management

Billing and management. Consolidated billing sits in Management, so every account is its own cost line in Cost Explorer with no tagging work. Savings Plans bought there are shared across the organization. Every account gets a monthly budget that alerts at 50, 80 and 100 percent, and Cost Anomaly Detection runs for the whole organization. Accounts, OUs, Control Tower, Identity Center and the organization rules cost nothing; Config, GuardDuty, Security Hub, Inspector, Macie, CloudTrail data events, Security Lake storage and the Backup vault are paid by volume. One Terraform stack creates the Control Tower landing zone, the OUs, the policies, the delegated administrators and the accounts, and every new account gets the same baseline module.



## Network design

### VPC architecture

Every workload account has its own virtual private cloud (VPC) in each region it runs in, spread over three Availability Zones (AZs), and every VPC has the same four subnet tiers, set apart by what may reach the internet: public, private, internal and Lambda. Today there is one VPC per region, both 10.144.0.0/16, with public, private and internal tiers and a small bastion tier (Built). The Lambda tier, a VPC per account and a range of its own for every VPC are Not built yet.

Public subnets are the only place where anything may have a public Internet Protocol (IP) address. They hold only what has to face the internet: the public load balancers, and the network address translation (NAT) gateways that let the private subnets reach out. Their route table sends internet traffic to the internet gateway, the VPC's door to the internet.

Private subnets hold the EKS nodes and pods, the internal load balancer and RDS Proxy, the connection pool in front of the database. Nothing here may have a public IP address. Traffic goes out through the NAT gateway in the same zone, and nothing on the internet can open a connection in.

Internal subnets hold the databases and nothing else. Their route table has only the VPC's own local route: no internet gateway, no NAT gateway. That is why we want them. If a security group is opened by mistake, the database still cannot be reached from the internet, and the database itself cannot send data out, because no route leads outside the VPC. A database feature that calls an AWS service, an export to S3 for example, goes through a VPC endpoint, a private path to that service (Built for S3).

Lambda subnets are a small tier for functions that must sit inside the VPC, for example one that rotates the database password and so has to reach the database. Lambda creates one network interface per subnet and security group pair and shares it between functions, so a small range is enough. A tier of their own keeps functions off the addresses the pods need, and the internal subnets can admit them by address range. A function that needs the internet routes through the NAT gateway; one that only talks to the database uses the internal route table. The network module already supports both.

Subnet sizes follow the EKS cluster. The VPC CNI, the Container Network Interface plugin that connects pods to the VPC, gives every pod its own address from the private subnet, so pods use up addresses far faster than anything else. Each VPC is a /16, 65,536 addresses, and three quarters of it goes to the private tier: one /18 per zone, about 16,000 addresses each (Built). Public and internal subnets get a /22 per zone (Built), the Lambda tier a /26 per zone, and the rest stays free. If the pods ever outgrow the private tier, the VPC takes a second range from 100.64.0.0/10 for pods only, through the VPC CNI's custom networking, and the existing subnets stay as they are.

Every VPC takes its range from Amazon VPC IP Address Manager (IPAM), one pool for the whole organization, so no two VPCs overlap. Today both regions use 10.144.0.0/16. Two VPCs with the same range can never be peered, and a Transit Gateway cannot route between them, so the regions have no private path to each other. With IPAM ranges, either connection can be added the day it is needed.

Each zone gets its own NAT gateway (Not built yet). Today one NAT gateway in the first zone serves all three private subnets, so losing that zone cuts every node off the internet and off ECR. The network module already has the switch.

AWS services are reached through VPC endpoints, so that traffic stays on the AWS network and skips the NAT gateway: S3 through a gateway endpoint (Built); ECR, the Security Token Service (STS), Secrets Manager, CloudWatch Logs and Systems Manager through interface endpoints (Not built yet). Each endpoint's policy admits only our organization.

How a request reaches a service. The web app and the API take two paths, both Built.

The web app: web.prod.innovate.example points at CloudFront. CloudFront checks the request with AWS WAF and serves the React files from an Amazon Simple Storage Service (S3) bucket. In the target only CloudFront can read that bucket, through origin access control (OAC); today CloudFront reads it through the bucket's website endpoint, guarded by a secret request header. Nothing in the VPC is involved.

The API: api.prod.innovate.example points at the two static IP addresses of Global Accelerator. The accelerator takes the user onto the AWS network at the nearest edge location and hands the connection to the public Application Load Balancer (ALB) in the nearest healthy region, keeping the user's IP address. The ALB checks the request with AWS WAF, ends Transport Layer Security (TLS), the encryption behind HTTPS, and picks the service by host name: api. goes to the API, load. to the load-test service, a name without a rule gets 403. Each service's target group holds the pods' own IP addresses, kept current by the AWS Load Balancer Controller, so the request goes from the ALB straight to a pod. The pod reaches the database through RDS Proxy, which talks to Aurora on port 5432.

Services that only other services call go behind the internal load balancer in the private subnets (Built) and are never published. Calls out to a third party leave through the NAT gateway of the pod's zone, whose fixed address is the one the third party can allowlist.

### Securing the network

We secure the network in layers: only the edge faces the internet and every request is checked there; inside, each tier accepts traffic only from the tier in front of it; and organization rules keep it that way in every account. Two situations matter: someone on the internet attacking the application, and someone who already got in, through a bug in the API for example, trying to go further or send data out.

The edge. CloudFront and Global Accelerator are the only ways in. Both include AWS Shield Standard, which absorbs common network floods at no extra cost. AWS WAF, the Web Application Firewall, runs on CloudFront and on each public ALB and checks every request against our rules. Built today: AWS managed rules against known bad IP addresses, common web attacks and known bad inputs, plus SQL injection on the ALB; a blocklist of IP addresses on the ALB that we fill by hand; and a limit of 2,000 requests per IP address in five minutes. Not built yet: an allowlist for addresses we trust, a partner or the office, that skips the rate limit (the module has it, switched off); much lower limits on sign-in and sign-up than on reading data; the Anonymous IP list, which marks requests from Tor, VPN services and hosting providers, where most attack tools run, blocked on sign-in and counted elsewhere; Bot Control, which recognises scanners and scripts that say what they are; account takeover prevention on sign-in, which flags attempts with stolen passwords. All WAF logs go to Log Archive.

Forged requests. A tool like Burp Suite sits between the browser and our API: someone uses the app normally, catches a real request, changes it, say another user's ID or a field the form never sends, and sends it again, once or thousands of times. AWS WAF makes that expensive. The React app gets a token through the AWS WAF JavaScript integration and sends it with every API call. Bot Control's targeted rules then challenge an address that keeps sending requests without a valid token and block a token that shows up from more than eight IP addresses within five minutes (Not built yet). That stops scripted replay. It cannot stop one careful person editing one request inside their own signed-in session, because that request looks exactly like a real one. Only the API stops that: on every request it checks who the user is and whether they may touch that record, and it checks every input against what the endpoint expects.

Inside the VPC. Security groups, the firewall on each network interface, chain the tiers. The public ALB takes web traffic from the internet, and Aurora takes 5432 only from RDS Proxy (Built). RDS Proxy takes 5432 from the whole VPC today; in the target only from the API pods, which get a security group of their own through EKS security groups for pods (Not built yet). Kubernetes network policies, which the VPC CNI enforces, block pod-to-pod traffic a service does not need, so a broken pod cannot reach every other service (Not built yet). A network access control list (ACL) on the internal subnets admits the database port only from the private and Lambda ranges, a second lock that does not depend on security groups (Not built yet).

Outbound. Private subnets reach the internet only through the NAT gateways. Route 53 Resolver DNS Firewall blocks Domain Name System (DNS) lookups of known malware and command-and-control domains in every VPC, so a compromised pod cannot easily call home (Not built yet). If a compliance rule asks for inspection of outbound traffic, AWS Network Firewall goes in front of the NAT gateways with a list of allowed domains.

Rules above the accounts. The declarative policy that turns on IMDSv2 also turns on VPC Block Public Access in ingress-only mode in every account: internet traffic can enter only subnets the account excludes, and Terraform excludes only the public subnets. A public IP address put on anything else gets no traffic from the internet, whatever its route table says. NAT gateways keep working, because they only open connections outward (Not built yet).

Admin access. Today the cluster's public API endpoint admits one address, the machine that ran Terraform; the bastion has a public IP address in a subnet of its own; and the Argo CD web interface sits on an internet-facing load balancer with its built-in admin login. In the target the cluster API endpoint is private only, the bastion moves into the private subnets without a public address, and people reach both through Session Manager, part of AWS Systems Manager (SSM), over VPC endpoints. Argo CD moves to the internal load balancer behind the company sign-in. The pipeline that applies the cluster components then runs on a GitHub Actions runner inside the VPC; if that runner is down, cluster changes wait and running workloads carry on (Not built yet).

Encryption and logs. TLS ends at CloudFront and at the ALBs; behind them traffic is plain HTTP today. Because the data is sensitive, the ALB encrypts again to the pods with HTTPS target groups (Not built yet). VPC Flow Logs record rejected connections and stay 60 days in the account today; in the target all flow logs, WAF logs and load balancer logs go to Log Archive.

## Compute platform

### Kubernetes: deploying and managing the application

The application runs on Amazon Elastic Kubernetes Service (EKS), one cluster in each workload account and region, and Argo CD inside each cluster deploys it from Git. Today there is one cluster per region with Karpenter, the AWS Load Balancer Controller, external-dns, the EBS CSI driver that gives pods disks, metrics-server and Argo CD, each installed by its own Terraform stack (Built). In the target the same Terraform runs once per account with that account's values: one cluster in Dev, one in Staging, one per region in Prod (Not built yet).

Upgrades. A Kubernetes upgrade goes to Dev first, then Staging, then Prod, one minor version at a time, and the EKS managed add-ons move with it. Karpenter notices a new node image and replaces the nodes by itself, within its disruption budget (Built). Every cluster takes the newest Amazon Machine Image (AMI) today; in the target Prod pins the version that passed Staging (Not built yet).

Access. People reach a cluster with their IAM Identity Center sign-in, and an EKS access entry maps their permission set to Kubernetes rights: write in Dev, read-only in Staging and Prod (Not built yet). Nobody deploys to Staging or Prod with kubectl. Controllers get AWS rights through EKS Pod Identity, one role each (Built), and services read their secrets from Secrets Manager through the Secrets Store CSI driver.

### Node groups, scaling and resource allocation

A small EKS managed node group runs the cluster's own controllers, and Karpenter launches every node the applications run on, x86 or Graviton, on Spot first and On-Demand when Spot is short. Today the controllers run on two managed node groups, one Graviton and one x86, both on Spot. Karpenter has two NodePools, the sets of instance types it may launch: x86, the default, and Graviton, which pods opt into through a taint, a mark that keeps other pods off those nodes. Both use recent compute, general-purpose and memory-optimized instance types (Built).

What changes (Not built yet):

The controllers' node group moves to On-Demand Graviton, at least two nodes in different zones. Karpenter runs there, and if Spot took its node back, nothing would launch new nodes until Karpenter was running again.

Graviton becomes the default pool for our own services. Both images are already built for x86 and Graviton, of-load already runs on Graviton, and Graviton instances cost less per hour than comparable x86 ones. The x86 pool stays for third-party images built only for x86.

In Prod every service keeps part of its replicas on On-Demand. Pods spread across Spot and On-Demand the way they already spread across zones, so a wave of Spot reclaims never takes all replicas at once. Savings Plans cover the steady On-Demand part.

Scaling. Each service scales its pods with the Horizontal Pod Autoscaler (HPA) on processor (CPU) and memory use. An API that mostly waits on the database shows load late in CPU, so in Prod KEDA, Kubernetes Event-driven Autoscaling, scales it on requests per pod from the ALB; the KEDA stack and the chart setting exist and are switched off (Not built yet). Nodes follow the pods: Karpenter adds a node when pods cannot be placed and removes nodes that are empty or underused, and each pool has a CPU ceiling, so a runaway scale-out hits a wall before it hits the bill (Built). Prod's ceilings come from load tests in Staging.

Growing from a few hundred users a day to millions needs no redesign: more pods, more nodes, more database readers. What to watch on the way: the pool ceilings, Spot capacity in the region, the database writer, and free addresses in the private subnets.

Resource allocation. Every container states how much CPU and memory it needs; Karpenter picks node sizes from that, and the HPA measures use against it. Each service has its own namespace, and a PodDisruptionBudget keeps all but one replica running while nodes are replaced. Not built yet: a LimitRange that gives a default to any container that forgets, a ResourceQuota per namespace so one service cannot take the whole cluster, and PriorityClasses so the API and the controllers win over batch work when capacity is short.

### Containerization: image building, registry, deployment

Every service is built once by GitHub Actions into one image for both x86 and Graviton, kept in Amazon Elastic Container Registry (ECR) under a tag that never changes, and deployed by a commit to the GitOps repository that Argo CD applies; the same image then moves from Dev to Staging to Prod.

CI/CD today. Terraform writes each service repository's pipeline into it (Built), so every service runs the same reviewed pipeline, and a hand edit in a repository is overwritten on the next apply. A push or pull request to master runs the tests first, the API's against a real PostgreSQL. Then each architecture is built on its own native runner, x86 and arm64, and the API image has to answer on its health endpoint. On master both images go to ECR and are joined under one multi-architecture tag. Static analysis and dependency scans (CodeQL, Snyk, zizmor) run beside the build. Pipelines get AWS access through GitHub OpenID Connect (OIDC): short-lived credentials, for master only, and no AWS key stored in GitHub. The web app's pipeline builds once, keeps the build in S3, copies it to the web bucket and clears the CloudFront cache.

Versioning today. An image tag is the git commit hash, the SHA: one tag per architecture plus a joint tag for both, and no latest. ECR refuses to overwrite a tag, so a tag always means the same image (Built). release-please, a release tool that runs in GitHub Actions, opens a release pull request with a semantic version, vX.Y.Z; after the release it adds that version as a second tag to the image already built, without building again. No release has been cut yet. The web build is stored under its commit SHA. Helm chart versions are set by hand, and Argo CD reads the charts straight from Git.

GitOps today. Yes, it is in place: what runs in the cluster is written in Git, and Argo CD, inside each regional cluster, pulls it from the GitOps repository, of-helm. Terraform creates one Argo CD Application per service and region, pointing at the service's chart on master (Built). Argo CD applies changes on its own, removes what was deleted from Git and reverts what someone changed by hand in the cluster. Both regions read the same values file, so one commit deploys both regions at once. The missing step is between the build and Git: today a person commits each new image tag into of-helm by hand. In the target the GitOps repository has one values file per environment and region, so a commit can go to Dev without touching Prod (Not built yet).

The deployer. Developers should not have to think about Argo CD. They deploy with our own deployer, of-launch: sign in with the company login, pick the environment, the service and a build, click deploy. The deployer commits that build's tag to the GitOps repository and asks Argo CD to sync; the commit is the audit record, and the deployer shows who deployed which build where and when. Rolling back is deploying the previous build. Argo CD's own interface stays open read-only for anyone who wants to watch a sync.

Deploy rules (Not built yet). Dev deploys every merge to master by itself. Staging and Prod deploy through the deployer, Prod takes only a build that has run in Staging, and a deploy to Prod needs a second person's approval. That keeps the rule from the account structure: every change to production is a commit plus a pipeline run, and nobody has write access to Prod.

Today of-launch is a Flask app on one EC2 virtual machine, outside this repository's Terraform, with its own user list. It has the flow and a deploy history, but its cluster deploy does not work against today's charts: it expects another values format and Application name, knows only one Argo CD, and reports success without checking. It needs the company sign-in, one Argo CD per cluster, the result read back from Argo CD and the deploy rules above (Not built yet).

Registry. Today ECR sits in the one account in us-east-1, scans each image on push, refuses tag overwrites, and copies the API and load-service images to us-west-2 so the second region can pull while us-east-1 is down (Built). In the target there is one registry in Shared Services, copied to the second region; workload accounts pull through ECR VPC endpoints, allowed by the repository policy (Not built yet).

Supply chain. Today the scans run beside the build and block nothing, master needs no review, and the builds switch off their software bill of materials (SBOM) and their provenance record, which says how and from what an image was built. In the target a pull request needs a review and green tests and scans before it merges; builds keep the SBOM and provenance; Amazon Inspector rescans stored images when a new vulnerability is published; and images are signed at build and checked by an admission policy before a pod may start (Not built yet).

Infrastructure. Infrastructure changes have their own pipeline: today an operator starts it by hand, it plans with a read-only role, and it applies after an approval (Built). In the target it plans on every pull request and applies on merge, in each account, as the account structure describes (Not built yet).

## Database

### PostgreSQL service and why

We use Amazon Aurora PostgreSQL as a global database: a writer and a reader in us-east-1, and a read-only copy in us-west-2. The application is written for PostgreSQL, so we keep PostgreSQL and let AWS run it.

Why Aurora:

Aurora keeps six copies of the data across three AZs, so losing a zone loses no data.

When the writer fails, a reader in another zone takes over, usually in under a minute.

A global database copies every change to the second region, typically within seconds, and promotes that copy in minutes as one managed step that keeps the database's address. RDS for PostgreSQL gets there only by promoting a cross-region replica and pointing every client at its new address.

Readers share the writer's storage, so more read capacity for millions of users means adding readers, up to 15, without copying data.

Running PostgreSQL ourselves on EKS would leave backups, failover, patching and encryption to us, for the most sensitive data we hold.

RDS Proxy sits in front of the database (Built). It pools connections, so hundreds of API pods do not run the database out of connections, and it keeps the application's connections open while a reader is promoted.

Capacity. Today the cluster is one db.t4g.medium instance (Built), a class that cannot join a global database. The target starts on Aurora Serverless v2, which grows and shrinks in small steps with the load and bills what it uses, so a quiet start costs little. When the load is high and steady, the writer moves to a provisioned instance with a reservation, which costs less at constant use; the readers can stay on Serverless v2, because one cluster can mix both (Not built yet).

Encryption and credentials. The data is encrypted with a customer managed key (CMK) of the Prod account (Not built yet). Today it uses the AWS managed key, which also blocks copying snapshots to another account. The password sits in Secrets Manager and reaches the pods through the Secrets Store CSI driver (Built); IAM authentication between the pods and RDS Proxy takes the shared password out of the application (Not built yet).

### Backups, high availability, disaster recovery

Aurora backs up continuously, a reader in a second zone covers a failed writer, the copy in us-west-2 covers a lost region, and the Backup account covers a lost or compromised Prod account.

Backups. Aurora's continuous backup restores the database to any point within the retention window; Prod keeps 35 days, the most Aurora allows (Not built yet; today 1 day). An organization backup policy takes a daily snapshot with AWS Backup and copies it to a logically air-gapped vault in the Backup account in us-west-2. That vault is always locked: nobody, an administrator of the Backup account included, can delete a copy before it expires. AWS Backup restore testing restores a recent copy on a schedule and checks it, so we know a backup works before we need it. Deletion protection is on, and a final snapshot is taken before any delete (Not built yet; today both are off).

High availability. In us-east-1 the cluster runs a writer and a reader in different zones; us-west-2 keeps at least one reader. When the writer fails, Aurora promotes the reader, usually in under a minute, and RDS Proxy moves the connections (Not built yet). Today there is one instance, so a failure means Aurora builds a new one, typically within ten minutes.

Disaster recovery. us-west-2 holds the global database's secondary cluster, a copy that trails by seconds and only reads until it is promoted (Not built yet). Aurora never moves the writer to another region by itself. A planned switchover loses nothing; an unplanned failover can lose the last seconds of writes. The failover function in us-west-2 takes us-east-1 out of traffic by setting its traffic dial, the share of new connections the accelerator sends to a region, to 0, then promotes us-west-2 (Built, started by hand). In the target a CloudWatch alarm on us-east-1's health starts it from outside us-east-1, and a person approves until drills show the alarm fires only for real outages (Not built yet). If losing the last seconds of writes is not acceptable, the rds.global_db_rpo setting makes the writer wait while the copy lags too far behind, trading write availability for a known maximum loss.

| What fails | What takes over | Data lost (recovery point, RPO) | Back in (recovery time, RTO) |
| --- | --- | --- | --- |
| The writer, or its zone | The reader in another zone | None | Usually under a minute |
| The us-east-1 region | The us-west-2 copy, promoted | The last seconds of writes | Minutes after the failover starts |
| A bad change, such as a dropped table | A point-in-time restore into a new cluster, from which the lost data is copied back | None, if we know when it happened | As long as the restore takes |
| The Prod account, taken over or encrypted | A restore from the Backup account's vault | Everything since the last daily copy | As long as the restore takes |

Where the design is weakest:

Traffic moves by itself, the database does not. The accelerator sends users to us-west-2 as soon as the us-east-1 ALB looks unhealthy, even with the us-west-2 traffic dial at 0, and writes fail there until the copy is promoted.

The accelerator counts an ALB healthy only when every target group behind it has a healthy target. Today the public ALB carries one target group nothing fills, so both regions look unhealthy and failover cannot work. When nothing is healthy, the accelerator sends traffic to a random endpoint in the nearest region, a dead one included.

During a failover Aurora tries to stop writes in the old region but cannot promise it, which is why the function takes us-east-1 out of traffic before it promotes.

A bad change reaches every copy within seconds. Only the backups undo it.

## Improvements on today's build

Every item is Not built yet. They are in the order we would do them: first what makes today's two regions work, then what makes them fit for sensitive data, then the move into the organization.

Edge target group: the public ALB carries a target group nothing fills, so the accelerator sees both regions as unhealthy and cannot fail over. Fill it or remove it.

NAT gateways: one serves all three zones, and losing its zone cuts every node off the internet and off ECR. One per zone.

Database: one db.t4g.medium, one day of backups, no deletion protection, no final snapshot, the AWS managed key. Serverless v2, a reader in a second zone, 35 days of backups, deletion protection, a final snapshot and a customer managed key; then the global database with its us-west-2 copy.

Database access: RDS Proxy accepts the whole VPC on 5432. Only the API pods.

Failover trigger: the failover function is started by hand. An alarm outside us-east-1 starts it, with a person approving until drills prove the alarm.

Address ranges: both regions use 10.144.0.0/16, so they can never be joined privately. A range per VPC from IPAM; for us-west-2 that means rebuilding its VPC.

VPC endpoints: only S3 has one. Interface endpoints for ECR, STS, Secrets Manager, CloudWatch Logs and Systems Manager.

Public exposure: the bastion has a public IP address outside the public subnets, the cluster API has a public endpoint, and Argo CD sits on an internet-facing load balancer with its built-in admin login. Bastion and Argo CD on private addresses behind Session Manager and the company sign-in, a private cluster API, and VPC Block Public Access.

Web bucket: CloudFront reads it through the public website endpoint, guarded by a secret header, and CloudFront access logs are off. Origin access control and access logs on.

Controllers: Karpenter and the other controllers run on Spot. On-Demand Graviton for the system node group.

Scaling: KEDA is in the code and kept out of the rollout. On in Prod, scaling the API on requests.

Release path: a person commits every image tag into of-helm, and of-launch's cluster deploy does not work against today's charts. of-launch fixed as described above and made the way to deploy, with values per environment and region in of-helm.

Pipeline gates: scans block nothing and master needs no review. Required reviews and checks, with SBOM, provenance and image signing on.

Cluster hardening: the cluster code turns on no control plane logs and no customer managed key for Kubernetes Secrets, and the developers' role does not require MFA. Control plane logging, envelope encryption for Secrets, and MFA on the role until Identity Center replaces it.

Terraform state: the backend has no lock, so two applies of the same stack can overlap. use_lockfile on the S3 backend.

Then the organization: Control Tower creates the landing zone and the accounts, Identity Center replaces the IAM users and the developer group, and each stack moves to its account. The registry, the parent DNS zone and the Terraform state go to Shared Services; the backup bucket goes to Backup; network, cluster, database and edge go to Dev, Staging and Prod, with both production regions inside Prod.

## Glossary

Abbreviations and names used in this document, with what each means here.

| Term | Stands for and what it is here |
| --- | --- |
| Access entry | EKS's list of which IAM roles may call the cluster API and with which Kubernetes rights |
| ACL | Access control list; a network ACL filters a subnet, a web ACL is a WAF rule set, S3 ACLs are switched off by "bucket owner enforced" |
| Add-on | A cluster component EKS installs and upgrades: `vpc-cni` (pod networking), `coredns` (cluster DNS), `kube-proxy` (service routing), pod-identity-agent |
| ALB | Application Load Balancer; the public ALB behind the accelerator, the internal ALB, and the Ingress ALB the load balancer controller builds |
| AMI | Amazon Machine Image, the disk image a node boots from; `al2023@latest` is the newest Amazon Linux 2023 |
| Anonymous IP list | AWS WAF managed rule group that marks requests from Tor, VPN services and hosting providers |
| API | Application programming interface; here the Flask REST API the web app calls |
| Argo CD | GitOps controller inside the cluster; pulls the of-helm repository and applies what it finds |
| AWS | Amazon Web Services |
| AZ | Availability Zone, one data-center group in a region; Multi-AZ means copies in two or more |
| Baseline | The Terraform module applied to every new account: default VPC removed, encryption defaults, OIDC provider, deploy role, budget, tags |
| Bastion | The one EC2 host in the VPC an operator reaches through SSM Session Manager to get at private resources |
| Bot Control | AWS WAF managed rule group for bots; its targeted level checks each request for a token only a real browser running the app gets |
| BreakGlass | The time-boxed, paged permission set for writes in Staging, Prod and Backup |
| Burp Suite | Proxy tool that catches, edits and replays web requests, used for security testing and for attacks |
| CD | Continuous delivery; here Argo CD pulling the GitOps repository into the cluster |
| CDC | Change data capture; streams each insert, update and delete out of the database as it happens, instead of copying whole tables |
| CI | Continuous integration; the GitHub Actions workflows that test, build, push images and run Terraform |
| CLI | Command-line interface; here the `aws` command |
| CloudFront | AWS content delivery network; serves the web app from S3 with WAF in front |
| CMK | Customer managed key, a KMS key the account creates and controls, unlike an AWS-managed key |
| CNI | Container Network Interface; the VPC CNI gives every pod an IP address from the VPC and enforces network policies |
| CodeQL, Snyk, zizmor | Scanners in CI: code analysis, known vulnerabilities in code and dependencies, mistakes in GitHub Actions workflows |
| Control Tower | AWS service that creates and governs the organization: landing zone, OUs, account vending, organization policies |
| CPU | Processor; Karpenter NodePools cap the total CPU they may launch |
| CSI | Container Storage Interface; the EBS CSI driver gives pods volumes, the Secrets Store CSI driver mounts Secrets Manager values |
| Delegated administrator | The member account that runs an organization-wide service (GuardDuty, Security Hub, Identity Center) instead of Management |
| DNS | Domain Name System; Route 53 holds the zones |
| DNS Firewall | Route 53 Resolver DNS Firewall; blocks DNS lookups of listed domains, such as known malware and command-and-control domains |
| DR | Disaster recovery; the second region and the Backup account |
| EBS | Elastic Block Store, the node and pod disks; gp3 is its general-purpose volume type |
| EC2 | Elastic Compute Cloud, the virtual machines nodes run on |
| ECR | Elastic Container Registry; holds the images |
| EKS | Elastic Kubernetes Service, the managed Kubernetes cluster |
| ETL, ELT | Extract, transform, load, or extract, load, transform: a pipeline that copies data from one store to another, cleaning or reshaping it before or after the copy |
| external-dns | Controller that writes Route 53 records for Kubernetes Ingresses and Services |
| FIDO2 | Open standard for hardware security keys used as the second sign-in factor |
| Flow Logs | VPC records of connections; today rejected traffic only |
| GitOps | Cluster state declared in a Git repository and pulled by a controller, not pushed by a pipeline |
| Global Accelerator | Static anycast IP addresses in front of each region's public ALB, with health-based failover between regions |
| Graviton | AWS's ARM CPUs (arm64); x86 and amd64 mean Intel and AMD |
| GuardDuty, Security Hub, Inspector, Macie, Config, Access Analyzer | AWS detective services: threat findings, finding aggregation and checks, vulnerability scans, sensitive-data discovery, configuration history, unintended-access analysis |
| Helm, chart | Kubernetes package manager; a chart is a templated set of manifests driven by a values file |
| HPA | Horizontal Pod Autoscaler; adds or removes pods on CPU or memory from metrics-server |
| HTTP, HTTPS | Hypertext Transfer Protocol, and its form encrypted with TLS |
| IAM | Identity and Access Management: roles, policies and, today, users and groups |
| ID | Identifier, such as a user's number in the database |
| Identity Center | IAM Identity Center, formerly AWS SSO; one sign-in through the company directory, then a permission set per account |
| IMDSv2 | Instance Metadata Service version 2, the token-protected way a node reads its metadata and credentials; the hop limit decides whether pods can reach it |
| Internet gateway | The VPC's connection to the internet; only the public subnets route to it |
| IP address | Internet Protocol address; a public one can be reached from the internet |
| IPAM | Amazon VPC IP Address Manager; hands out address ranges from one pool so no two VPCs overlap |
| Karpenter | Node autoscaler; launches EC2 instances for pending pods and removes them when empty |
| KEDA | Kubernetes Event-driven Autoscaling; scales pods on external metrics such as ALB requests per minute |
| KMS | Key Management Service, the encryption keys |
| Landing zone | Control Tower's starting setup: the organization, the Security OU accounts, logging and the organization policies |
| LimitRange, ResourceQuota | Kubernetes objects: a default size for containers that set none, and a ceiling for a whole namespace |
| Logically air-gapped vault | AWS Backup vault that is always locked in compliance mode; nobody can delete a copy before it expires |
| Managed node group | EKS-managed set of EC2 nodes; here the system nodes the controllers run on |
| metrics-server | Collects pod and node CPU and memory for the HPAs and `kubectl top` |
| MFA | Multi-factor authentication |
| NAT gateway | Lets private subnets reach the internet outbound while staying unreachable inbound |
| Network policy | Kubernetes rule for which pods may talk to which |
| NodePool | Karpenter object: the instance types, capacity types, architecture, limits and taint a set of nodes may use |
| OAC | Origin access control; lets only the CloudFront distribution read the S3 bucket |
| Object Lock | S3 setting that blocks deleting or changing objects for a retention period |
| OIDC | OpenID Connect; GitHub Actions gets AWS credentials with a signed token instead of stored keys |
| On-Demand, Spot | EC2 pricing: On-Demand is full price and stays; Spot is spare capacity at a discount that AWS reclaims with two minutes' warning |
| OU | Organizational unit, a folder of accounts in an AWS Organization that policies attach to |
| PCI, SOC 2, HIPAA | Compliance regimes: card payments, service-organization controls, US health data |
| Permission set | Identity Center's role template; becomes a role in each account it is assigned to |
| Pod Identity | EKS Pod Identity; binds a Kubernetes service account to an IAM role through the pod-identity agent, no OIDC trust per role |
| PodDisruptionBudget | How many pods of a Deployment may be down while nodes drain; here all but one stay up |
| PriorityClass | Kubernetes object that decides which pods keep running when capacity is short |
| RDS Proxy | Managed connection pool between the application and the database; keeps connections open during a failover |
| RDS, Aurora | Relational Database Service; Aurora is its PostgreSQL-compatible engine, Serverless v2 scales its capacity, a global database replicates to another region |
| release-please | Release tool in GitHub Actions that opens release pull requests and tags semantic versions |
| Resource Access Manager | AWS service that shares resources such as a Transit Gateway across accounts |
| Resource control policy | Organization policy on the resource side (S3, KMS, Secrets Manager, SQS, STS) limiting who may call it |
| REST | Representational state transfer; the request style of the Flask API |
| Route 53 | AWS DNS; the hosted zones and their records |
| RPO, RTO | Recovery point objective, the data a failover may lose; recovery time objective, how long until service is back |
| S3 | Simple Storage Service, the buckets |
| SBOM | Software bill of materials, the list of packages in an image |
| Secrets Manager | AWS secret store; the Secrets Store CSI driver mounts its values into pods |
| Security group | Stateful firewall on an instance, ALB or pod network interface |
| Service control policy | Organization-wide rule that caps what anyone in an account may do, inherited down the tree, never applied to Management |
| SHA | The hash git gives each commit; it names each image |
| Shield Standard | AWS protection against common network floods, included at no extra cost on CloudFront and Global Accelerator |
| SIEM | Security information and event management, the tool that collects and correlates security logs |
| SOC | Security operations center |
| SQL | Structured Query Language; SQL injection smuggles database commands into a request |
| SSM | Systems Manager; Session Manager opens a shell on the bastion with no SSH port open |
| SSO | Single sign-on |
| Stack, module, rollout | Terraform layout: a stack is one root with its own state, a module a building block under `modules/`, `rollout` the apply order |
| STS | Security Token Service; issues the short-lived credentials behind every assumed role |
| Taint | Node mark that keeps pods away unless they tolerate it; the Graviton pool is opt-in through its taint |
| Target group | The set of targets, here pod IPs, an ALB listener rule sends traffic to |
| TLS | Transport Layer Security, the HTTPS encryption; the TLS 1.2 and 1.3 policies name the allowed versions |
| Traffic dial | Global Accelerator's share of new connections sent to one region |
| Transit Gateway | Hub that routes between VPCs and on-premises; not used, nothing needs VPC-to-VPC traffic |
| VPC | Virtual Private Cloud, the private network with its subnets |
| VPC Block Public Access | VPC setting that blocks internet traffic to every subnet not excluded; here only the public subnets are excluded |
| VPC endpoint | Private path from the VPC to an AWS service without the internet; an interface endpoint is a network interface in the VPC, a gateway endpoint a route-table entry |
| VPN | Virtual private network |
| WAF | Web Application Firewall; rule sets on CloudFront and the public ALB |
