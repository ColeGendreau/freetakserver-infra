# FreeTAKServer Infrastructure

Terraform project to deploy [FreeTAKServer](https://freetakteam.github.io/FreeTAKServer-User-Docs/) on DigitalOcean.

## What Gets Deployed

- **Ubuntu 22.04** droplet (2 GB RAM, 1 vCPU) — ~$12/mo
- **Firewall** with ports opened for all FTS services
- **FreeTAKServer 2.x** installed via the official Zero Touch Installer, including:
  - FTS core (CoT on port 8087, SSL CoT on port 8089)
  - FTS Web UI (port 5000)
  - REST API (port 19023)
  - WebMap (port 8000)
  - Node-RED integration server (port 1880)
  - Mumble voice server (port 64738)
  - Video server / MediaMTX (port 8554)

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
2. A [DigitalOcean account](https://cloud.digitalocean.com/registrations/new) and [API token](https://cloud.digitalocean.com/account/api/tokens)
3. An SSH key pair (`ssh-keygen -t ed25519` if you don't have one)

## Quick Start

```bash
# Clone and enter the directory
cd freetakserver-infra

# Set up your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your DO token and SSH key path

# Deploy
terraform init
terraform plan
terraform apply

# Check installation progress (takes ~10-15 min after droplet is up)
ssh root@$(terraform output -raw droplet_ip) 'tail -f /var/log/fts-install.log'
```

## Connecting ATAK/iTAK

After installation completes (~10-15 minutes after the droplet is running):

1. Open ATAK/iTAK
2. Go to Settings > Network Preferences > TAK Servers
3. Add a new server:
   - **Host**: `<droplet_ip>` (from `terraform output droplet_ip`)
   - **Port**: `8087` (plaintext) or `8089` (SSL)
   - **Protocol**: TCP

## Useful Commands

```bash
# See all outputs (IPs, URLs, etc.)
terraform output

# SSH into the server
ssh root@$(terraform output -raw droplet_ip)

# Check FTS service status
ssh root@$(terraform output -raw droplet_ip) 'systemctl status fts'

# Tear everything down
terraform destroy
```

## Ports Reference

| Service | Port | Protocol |
|---------|------|----------|
| SSH | 22 | TCP |
| CoT (plaintext) | 8087 | TCP |
| CoT (SSL) | 8089 | TCP |
| REST API | 19023 | TCP |
| Web UI | 5000 | TCP |
| WebMap | 8000 | TCP |
| Node-RED | 1880 | TCP |
| Mumble Voice | 64738 | TCP/UDP |
| Video (RTSP) | 8554 | TCP |

## Cost

DigitalOcean `s-1vcpu-2gb` droplet: **$12/month** (2 GB RAM, 1 vCPU, 50 GB SSD, 2 TB transfer).

### Cheaper Alternatives

If you want to reduce cost, these providers have Terraform support:

| Provider | Plan | RAM | Price | Terraform Provider |
|----------|------|-----|-------|--------------------|
| Hetzner | CX23 | 4 GB | ~$4/mo | `hetznercloud/hcloud` |
| IONOS | VPS S | 2 GB | $5/mo | `ionos-cloud/ionoscloud` |

## Destroy

```bash
terraform destroy
```

This removes the droplet, firewall, and SSH key from DigitalOcean. Your local SSH keys and Terraform state are preserved.
