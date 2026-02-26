# OpenTAKServer Infrastructure

One-click deploy/destroy for [OpenTAKServer (OTS)](https://opentakserver.io/) on DigitalOcean using Terraform and GitHub Actions. Fork this repo, add two secrets, click **deploy**, and you have a fully functional TAK server with automatic certificate management in ~15 minutes.

## What Gets Deployed

A single DigitalOcean droplet running Ubuntu 22.04 with:

- **OpenTAKServer** — TCP and SSL Cursor-on-Target (CoT) streaming
- **Web UI** — browser-based admin dashboard with user authentication
- **Automatic CA** — certificate authority generated on first boot; no manual cert wrangling
- **Certificate Enrollment** — clients (ATAK/iTAK) auto-enroll for client certs via the server
- **MediaMTX** — RTSP video streaming and recording
- **RabbitMQ** — message broker for CoT routing
- **Nginx** — TLS termination and reverse proxy
- **DigitalOcean Firewall** — only required ports are exposed

## Prerequisites

- A **GitHub** account (free)
- A **DigitalOcean** account ([sign up](https://cloud.digitalocean.com/registrations/new)) with a payment method on file
- An **SSH key pair** on your local machine (used to SSH into the server for troubleshooting)

If you don't have an SSH key yet:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

This creates `~/.ssh/id_ed25519` (private) and `~/.ssh/id_ed25519.pub` (public).

## Quick Start (Fork & Deploy)

### Step 1 — Fork this repository

Click the **Fork** button at the top-right of this repo. This creates your own copy under your GitHub account.

### Step 2 — Create a DigitalOcean API token

1. Log in to [DigitalOcean](https://cloud.digitalocean.com/)
2. Go to **API** in the left sidebar (or visit [cloud.digitalocean.com/account/api/tokens](https://cloud.digitalocean.com/account/api/tokens))
3. Click **Generate New Token**
4. Give it a name (e.g. `opentakserver`), select **Read + Write** scope, and click **Generate Token**
5. Copy the token immediately — you won't be able to see it again

### Step 3 — Add secrets to your fork

In your forked repo on GitHub:

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret** and add each of these:

| Secret Name | Value | How to get it |
|-------------|-------|---------------|
| `DO_TOKEN` | Your DigitalOcean API token | Step 2 above |
| `SSH_PUBLIC_KEY` | Contents of your public key | Run `cat ~/.ssh/id_ed25519.pub` and paste the output |

The `SSH_PUBLIC_KEY` value should look like:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... your_email@example.com
```

### Step 4 — Deploy

1. In your fork, go to the **Actions** tab
2. You may see a banner saying "Workflows aren't being run on this fork" — click **I understand my workflows, go ahead and enable them**
3. In the left sidebar, click **OpenTAKServer**
4. Click **Run workflow** > select **deploy** > click the green **Run workflow** button

The workflow will:
- Provision a DigitalOcean droplet (~1 minute)
- Install OpenTAKServer via cloud-init (~10-15 minutes in the background)

### Step 5 — Find your server IP

After the workflow completes (green check), click into the run and expand the **Show Outputs** step. You'll see:

```
droplet_ip = "YOUR_SERVER_IP"
web_ui_url = "https://YOUR_SERVER_IP"
ssl_cot_url = "YOUR_SERVER_IP:8089"
cert_enrollment_url = "https://YOUR_SERVER_IP:8446"
truststore_url = "https://YOUR_SERVER_IP/api/truststore"
```

### Step 6 — Wait for installation to finish

The droplet is provisioned quickly, but OTS installs in the background via cloud-init. Monitor progress by SSHing in:

```bash
ssh root@YOUR_SERVER_IP 'tail -f /var/log/ots-install.log'
```

When you see the banner below, the server is ready:

```
=========================================
  OpenTAKServer Installation Complete!
=========================================
```

### Step 7 — Log in to the Web UI

1. Open `https://YOUR_SERVER_IP` in your browser
2. You'll get a certificate warning (self-signed cert) — click **Advanced** > **Proceed** to accept it
3. Log in with the default credentials:
   - **Username:** `administrator`
   - **Password:** `password`
4. **Change the password immediately** after logging in (top-right menu > Profile)

## Connecting TAK Clients

OpenTAKServer handles certificates automatically. You do **not** need to manually create or distribute certificate files. Clients enroll by authenticating with their username/password, and the server issues them a client certificate.

### Create a user account

Before connecting a client, create a user account in the OTS Web UI:

1. Log in to `https://YOUR_SERVER_IP` as `administrator`
2. Navigate to the user management section and create a new user with a username and password

### iTAK (iOS)

1. On your iPhone, open Safari and download the truststore:

```
https://YOUR_SERVER_IP/api/truststore
```

2. Save the file when prompted (it will download as `truststore-root.p12`)
3. Open iTAK > **Settings** > **Network** > **Servers**
4. Tap **+** > **Connect with Credentials**
5. Fill in:
   - **Address:** `YOUR_SERVER_IP`
   - **Port:** `8089`
   - **Protocol:** SSL
   - **Username / Password:** your OTS credentials
6. When prompted to import the truststore, select the `truststore-root.p12` file you downloaded
7. Truststore password: `atakatak`
8. iTAK will auto-enroll for a client certificate and connect

### ATAK (Android)

1. Open ATAK > **Settings** > **Network Preferences** > **TAK Servers** > **Add**
2. Enter your server address: `YOUR_SERVER_IP`
3. Port: `8089`
4. Check **Use Authentication** and enter your OTS username/password
5. Check **Enroll for Client Certificate**
6. Protocol: **SSL**
7. Uncheck **Use default SSL/TLS Certificates**
8. Check **Enroll with Preconfigured Trust**
9. Import the truststore from `https://YOUR_SERVER_IP/api/truststore`
10. Truststore password: `atakatak`
11. Tap **OK** — ATAK will auto-enroll and connect

### WinTAK (Windows)

1. Download the truststore from `https://YOUR_SERVER_IP/api/truststore` and save it
2. Open WinTAK > **Settings** > **Network** > **Manage Server Connections**
3. Add a new server with address `YOUR_SERVER_IP`, port `8089`, protocol **SSL**
4. Enable authentication and enter your OTS credentials
5. Import the truststore (`atakatak` password) and enable certificate enrollment

## Certificates and Security

### How it works

On first boot, OTS automatically generates:

- A **Certificate Authority (CA)** at `/home/tak/ots/ca/`
- A **server certificate** at `/home/tak/ots/ca/certs/opentakserver/`
- A **truststore** downloadable at `https://YOUR_SERVER_IP/api/truststore`

When a TAK client connects with valid credentials, OTS automatically issues it a **client certificate** signed by the CA. No manual cert distribution required.

### Certificate locations on the server

| File | Path |
|------|------|
| CA certificate | `/home/tak/ots/ca/ca.pem` |
| CA private key | `/home/tak/ots/ca/ca-do-not-share.key` |
| Server certificate | `/home/tak/ots/ca/certs/opentakserver/opentakserver.pem` |
| Server private key | `/home/tak/ots/ca/certs/opentakserver/opentakserver.nopass.key` |
| Truststore (for clients) | `/home/tak/ots/ca/truststore-root.p12` |
| Client certs (auto-generated) | `/home/tak/ots/ca/certs/<username>/` |

### Truststore password

The default truststore password is `atakatak`. This is the standard TAK ecosystem default.

## Destroying the Server

When you're done, tear everything down to stop billing:

1. Go to **Actions** > **OpenTAKServer** > **Run workflow**
2. Select **destroy**
3. Click **Run workflow**

This deletes the droplet, firewall, and SSH key from DigitalOcean. Your DigitalOcean API token and GitHub secrets remain intact, so you can redeploy anytime.

## Local CLI Deploy (Alternative)

If you prefer running Terraform locally instead of using GitHub Actions:

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/opentakserver-infra.git
cd opentakserver-infra

# Configure your variables
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
do_token            = "dop_v1_your_token_here"
ssh_public_key_path = "~/.ssh/id_ed25519.pub"
```

Then deploy:

```bash
terraform init
terraform apply
```

Monitor the install:

```bash
ssh root@$(terraform output -raw droplet_ip) 'tail -f /var/log/ots-install.log'
```

Destroy when done:

```bash
terraform destroy
```

## Ports Reference

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| SSH | 22 | TCP | Server management |
| Web UI | 443 | TCP | HTTPS dashboard and API |
| HTTPS TAK | 8443 | TCP | TAK API with client cert auth |
| Certificate Enrollment | 8446 | TCP | Client certificate provisioning |
| SSL CoT | 8089 | TCP | Encrypted Cursor-on-Target streaming |
| Video (RTSP) | 8554 | TCP/UDP | Live video streaming via MediaMTX |
| Mumble Voice | 64738 | TCP/UDP | Push-to-talk voice (if enabled) |

## Cost

| Provider | Plan | RAM | vCPUs | Storage | Price |
|----------|------|-----|-------|---------|-------|
| **DigitalOcean** | `s-1vcpu-2gb` | 2 GB | 1 | 50 GB SSD | **$12/mo** |
| Hetzner | CX22 | 4 GB | 2 | 40 GB | ~$4/mo |
| IONOS | VPS S | 2 GB | 1 | 80 GB | ~$5/mo |

Destroy the server when not in use to avoid charges. Deploy/destroy takes ~1 minute via GitHub Actions (plus ~15 minutes for OTS to install on a fresh deploy).

## Troubleshooting

**Workflow fails on deploy:**
- Verify your `DO_TOKEN` secret is a valid DigitalOcean API token with read+write permissions
- Verify `SSH_PUBLIC_KEY` contains the full public key string (starts with `ssh-ed25519` or `ssh-rsa`)

**Can't SSH into the server:**
- Make sure you're using the private key that matches the public key you added as a secret
- `ssh -i ~/.ssh/id_ed25519 root@YOUR_SERVER_IP`

**Web UI shows 502 or 500 error:**
- OTS is probably still installing. Check `tail -f /var/log/ots-install.log` and wait for the completion banner
- If the install finished but the error persists: `ssh root@YOUR_SERVER_IP 'systemctl restart opentakserver nginx'`

**iTAK/ATAK won't connect:**
- Make sure you downloaded and imported the truststore first
- Confirm the port is `8089` and protocol is `SSL`
- Verify you created a user account in the OTS Web UI and are using those credentials
- Check the server is fully installed (the completion banner appears in the install log)

**Check service status:**

```bash
ssh root@YOUR_SERVER_IP 'for svc in opentakserver cot_parser eud_handler eud_handler_ssl mediamtx nginx rabbitmq-server; do printf "%-20s %s\n" "$svc" "$(systemctl is-active $svc)"; done'
```

All seven services should show `active`.

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │          DigitalOcean Droplet            │
                    │                                         │
  ATAK/iTAK ──────►│  :443   nginx ──► OTS Web UI (:8081)    │
  (SSL CoT)  ──────│  :8089  eud_handler_ssl ──► RabbitMQ    │
  (Certs)    ──────│  :8446  nginx ──► OTS enrollment         │
  (Video)    ──────│  :8554  MediaMTX                         │
                    │                                         │
                    │  OTS auto-generates CA + server certs   │
                    │  Clients auto-enroll via credentials    │
                    └─────────────────────────────────────────┘
```

## Links

- [OpenTAKServer Documentation](https://docs.opentakserver.io/)
- [OpenTAKServer GitHub](https://github.com/brian7704/OpenTAKServer)
- [ATAK (Android)](https://play.google.com/store/apps/details?id=com.atakmap.app.civ)
- [iTAK (iOS)](https://apps.apple.com/app/itak/id1610625892)
- [DigitalOcean API Tokens](https://cloud.digitalocean.com/account/api/tokens)
