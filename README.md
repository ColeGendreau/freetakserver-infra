# OpenTAKServer Infrastructure

One-click deploy/destroy for [OpenTAKServer](https://docs.opentakserver.io/) on DigitalOcean via Terraform and GitHub Actions.

## What Gets Deployed

- **Ubuntu 22.04** droplet (2 GB RAM, 1 vCPU) — ~$12/mo
- **Firewall** with only necessary ports exposed
- **OpenTAKServer** installed via the official installer, including:
  - TCP and SSL CoT streaming (port 8089)
  - Web UI with authentication (port 443)
  - Built-in certificate enrollment (port 8446)
  - MediaMTX video streaming (port 8554)
  - Mumble voice server (port 64738)
  - Data packages, DataSync, device profiles
  - ADS-B and AIS data feeds

## Fork & Deploy (GitHub Actions)

### 1. Fork this repo

### 2. Add your secrets

In your fork: **Settings > Secrets and variables > Actions**

| Secret | Value |
|--------|-------|
| `DO_TOKEN` | Your [DigitalOcean API token](https://cloud.digitalocean.com/account/api/tokens) (read + write) |
| `SSH_PUBLIC_KEY` | Contents of your SSH public key (`cat ~/.ssh/id_ed25519.pub`) |

### 3. Deploy

Go to **Actions > FreeTAKServer > Run workflow** and select **deploy**.

Wait ~15 minutes for OTS to install. Check progress:

```bash
ssh root@<DROPLET_IP> 'tail -f /var/log/ots-install.log'
```

### 4. Set up your account

1. Open `https://<DROPLET_IP>` in a browser (accept the self-signed cert warning)
2. Register an admin account

### 5. Connect ATAK/iTAK

**No data packages needed** — OTS has built-in certificate enrollment.

#### iTAK
1. Download the truststore: `https://<DROPLET_IP>/api/truststore` (save to your phone)
2. In iTAK: Settings > Network > Servers > + > Connect with Credentials
3. Address: `<DROPLET_IP>`, Port: `8089`, Protocol: SSL
4. Enter your OTS username and password

#### ATAK
1. Settings > Network Preferences > TAK Servers > Add
2. Enter server address and port `8089`
3. Check **Use Authentication** and enter your OTS credentials
4. Check **Enroll for Client Certificate**
5. Set protocol to **SSL**
6. Uncheck "Use default SSL/TLS Certificates"
7. Check **Enroll with Preconfigured Trust**
8. Import the truststore from `https://<DROPLET_IP>/api/truststore`
9. Truststore password: `atakatak`
10. Tap OK — ATAK will auto-enroll and connect

### 6. Destroy

**Actions > FreeTAKServer > Run workflow > destroy**

## Ports Reference

| Service | Port | Protocol |
|---------|------|----------|
| SSH | 22 | TCP |
| Web UI (HTTPS) | 443 | TCP |
| HTTPS TAK | 8443 | TCP |
| Certificate Enrollment | 8446 | TCP |
| SSL CoT | 8089 | TCP |
| Video (RTSP) | 8554 | TCP/UDP |
| Mumble Voice | 64738 | TCP/UDP |

## Local CLI Deploy

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform apply

ssh root@$(terraform output -raw droplet_ip) 'tail -f /var/log/ots-install.log'
```

## Cost

DigitalOcean `s-1vcpu-2gb`: **$12/month** (2 GB RAM, 1 vCPU, 50 GB SSD).

### Cheaper Alternatives

| Provider | Plan | RAM | Price | Terraform Provider |
|----------|------|-----|-------|--------------------|
| Hetzner | CX23 | 4 GB | ~$4/mo | `hetznercloud/hcloud` |
| IONOS | VPS S | 2 GB | $5/mo | `ionos-cloud/ionoscloud` |
