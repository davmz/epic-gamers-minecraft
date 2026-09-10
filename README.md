# epic-gamers-minecraft

Private modded Minecraft server running on AWS EKS.

This project is mainly for hands-on experience with AWS, Kubernetes, Terraform, automation, observability, Discord integrations, and future web tooling.

## Architecture

```text
Player
  ↓
AWS LoadBalancer
  ↓
Kubernetes Service
  ↓
Minecraft Deployment
  ↓
Minecraft Pod
  ↓
EBS Persistent Volume
```

AWS infrastructure currently includes:

- VPC
- public and private subnets
- Internet Gateway
- NAT Gateway
- EKS cluster
- EKS managed node group
- EBS CSI Driver
- EBS persistent storage
- S3 remote Terraform state
- GitHub OIDC authentication

## Repository Structure

```text
epic-gamers-minecraft/
├── kubernetes/
│   └── minecraft/
│       ├── namespace.yaml
│       ├── storageclass.yaml
│       ├── pvc.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── data-tools.yaml
│
├── scripts/
│   ├── server-start.sh
│   └── server-stop.sh
│
└── terraform/
    ├── modules/
    │   ├── vpc/
    │   ├── eks/
    │   └── ebs-csi/
    │
    └── environments/
        ├── dev/
        └── prod/
```

## Minecraft Server

current setup:

- Minecraft 1.21.11
- Fabric
- whitelist enabled
- survival
- normal difficulty
- maximum 7 players
- 8 GB JVM memory
- view distance 10
- simulation distance 10
- persistent EBS storage

Minecraft data is mounted at:

```text
/data
```

this includes:

```text
mods/
config/
world/
world_nether/
world_the_end/
whitelist.json
ops.json
server.properties
```

## Start Server

from the repository root:

```bash
./scripts/server-start.sh
```

this:

- scales the EKS node group to 1
- waits for the node to become Ready
- scales the Minecraft deployment to 1
- waits for Minecraft to start

## Stop Server

from the repository root:

```bash
./scripts/server-stop.sh
```

this:

- scales the Minecraft deployment to 0
- waits for the Minecraft pod to stop
- scales the EKS node group to 0
- keeps the EBS volume and world data

this is used to reduce EC2 costs when the server is not being used.

## Check Server

Minecraft pod:

```bash
kubectl get pods -n minecraft
```

Kubernetes nodes:

```bash
kubectl get nodes -L topology.kubernetes.io/zone
```

Minecraft logs:

```bash
kubectl logs -f deployment/minecraft -n minecraft
```

Minecraft LoadBalancer:

```bash
kubectl get svc minecraft -n minecraft
```

## Terraform

Terraform is used to manage the AWS infrastructure.

from:

```bash
cd terraform/environments/prod
```

run:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

the current Terraform modules are:

```text
vpc
eks
ebs-csi
```

the Minecraft node group is pinned to the same Availability Zone as the EBS volume because EBS volumes are Availability Zone specific.

## Performance Testing

Spark is installed for Minecraft server performance testing.

check TPS:

```text
/spark tps
```

start profiling:

```text
/spark profiler start
```

stop profiling:

```text
/spark profiler stop
```

main things to watch:

- TPS
- MSPT
- CPU usage
- memory usage
- slow ticks
- `Can't keep up!` warnings

## Planned

future work:

- Simple Voice Chat UDP networking
- S3 backups
- backup restore process
- Grafana monitoring
- Loki logs
- alerts
- Discord integration
- Minecraft to Discord chat
- Discord admin controls
- live map
- GitOps
- player/admin website
- whitelist management
- server restart controls
- backup controls
- server status page