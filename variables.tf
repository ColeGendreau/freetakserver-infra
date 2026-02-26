variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Droplet size slug (s-1vcpu-2gb = $12/mo)"
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "droplet_name" {
  description = "Name for the droplet"
  type        = string
  default     = "freetakserver"
}

variable "ssh_key_name" {
  description = "Name for the SSH key in DigitalOcean"
  type        = string
  default     = "fts-key"
}

variable "ssh_public_key" {
  description = "SSH public key content (used in CI, takes precedence over ssh_public_key_path)"
  type        = string
  default     = ""
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key (used for local development)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "fts_public_ip" {
  description = "Public IP to bind FTS to (leave empty to auto-detect)"
  type        = string
  default     = ""
}
