terraform {
  required_version = ">= 1.5"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "fts" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)
}

resource "digitalocean_firewall" "fts" {
  name        = "${var.droplet_name}-fw"
  droplet_ids = [digitalocean_droplet.fts.id]

  # SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # FTS CoT (SSL only — plaintext 8087 is blocked)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8089"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # FTS REST API
  inbound_rule {
    protocol         = "tcp"
    port_range       = "19023"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # FTS Web UI
  inbound_rule {
    protocol         = "tcp"
    port_range       = "5000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Web Map
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Mumble voice server
  inbound_rule {
    protocol         = "tcp"
    port_range       = "64738"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "64738"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Video server (RTSP)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8554"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Node-RED
  inbound_rule {
    protocol         = "tcp"
    port_range       = "1880"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # All outbound
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_droplet" "fts" {
  name     = var.droplet_name
  region   = var.region
  size     = var.droplet_size
  image    = "ubuntu-22-04-x64"
  ssh_keys = [digitalocean_ssh_key.fts.fingerprint]

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    fts_public_ip = var.fts_public_ip
  })

  tags = ["freetakserver"]

  lifecycle {
    create_before_destroy = true
  }
}
