# FreeTAKServer Infrastructure

One-click deploy/destroy for [FreeTAKServer](https://freetakteam.github.io/FreeTAKServer-User-Docs/) on DigitalOcean via Terraform and GitHub Actions.

## What Gets Deployed

- **Ubuntu 22.04** droplet (2 GB RAM, 1 vCPU) — ~$12/mo
- **Firewall** with only necessary ports open (SSL-only, no plaintext CoT)
- **FreeTAKServer 2.x** installed via the official Zero Touch Installer, including:
  - FTS core — SSL CoT on port **8443**
  - FTS Web UI (port 5000)
  - REST API (port 19023)
  - WebMap (port 8000)
  - Node-RED integration server (port 1880)
  - Mumble voice server (port 64738)
  - Video server / MediaMTX (port 8554)
- **Client data package** (`FTS-iTAK.zip`) auto-generated with SSL certs for iTAK/ATAK

## Fork & Deploy (GitHub Actions)

The easiest way to use this repo — no local Terraform needed.

### 1. Fork this repo

Click **Fork** at the top of this page.

### 2. Add your secrets

In your fork, go to **Settings > Secrets and variables > Actions** and add:

| Secret | Value |
|--------|-------|
| `DO_TOKEN` | Your [DigitalOcean API token](https://cloud.digitalocean.com/account/api/tokens) (read + write) |
| `SSH_PUBLIC_KEY` | Contents of your SSH public key (`cat ~/.ssh/id_ed25519.pub`) |

### 3. Deploy

Go to **Actions > FreeTAKServer > Run workflow** and select **deploy**.

### 4. Connect iTAK/ATAK

Once the deploy finishes (~10-15 min for FTS to install after the droplet is up):

```bash
# Download the auto-generated data package
scp root@<DROPLET_IP>:/opt/fts-datapackage/FTS-iTAK.zip .
```

Then transfer `FTS-iTAK.zip` to your phone and import it:
- **iTAK**: Settings > Network > Servers > + > Upload Server Package
- **ATAK**: Settings > Network Preferences > TAK Servers > Import

Certificate password: `atakatak`

### 5. Destroy

Go to **Actions > FreeTAKServer > Run workflow** and select **destroy**.

## Local CLI Deploy (Alternative)

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your DO token and SSH key path

terraform init
terraform plan
terraform apply

# Watch install progress
ssh root@$(terraform output -raw droplet_ip) 'tail -f /var/log/fts-install.log'

# Download client data package when install completes
scp root@$(terraform output -raw droplet_ip):/opt/fts-datapackage/FTS-iTAK.zip .
```

## Ports Reference

| Service | Port | Protocol | Auth |
|---------|------|----------|------|
| SSH | 22 | TCP | SSH key |
| CoT (SSL) | 8443 | TCP | Client certificate |
| REST API | 19023 | TCP | — |
| Web UI | 5000 | TCP | Account signup |
| WebMap | 8000 | TCP | — |
| Node-RED | 1880 | TCP | Token |
| Mumble Voice | 64738 | TCP/UDP | — |
| Video (RTSP) | 8554 | TCP | — |

> Plaintext CoT (8080) is **not exposed** in the firewall. All TAK client connections require SSL + client certificates.

## Cost

DigitalOcean `s-1vcpu-2gb` droplet: **$12/month** (2 GB RAM, 1 vCPU, 50 GB SSD, 2 TB transfer).

### Cheaper Alternatives

These providers also have Terraform support if you want to adapt this project:

| Provider | Plan | RAM | Price | Terraform Provider |
|----------|------|-----|-------|--------------------|
| Hetzner | CX23 | 4 GB | ~$4/mo | `hetznercloud/hcloud` |
| IONOS | VPS S | 2 GB | $5/mo | `ionos-cloud/ionoscloud` |

## Destroy

```bash
terraform destroy
```

Or use the GitHub Actions **destroy** workflow for one-click teardown.
