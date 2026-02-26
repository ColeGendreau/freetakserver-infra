output "droplet_ip" {
  description = "Public IP address of the OpenTAKServer droplet"
  value       = digitalocean_droplet.fts.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${digitalocean_droplet.fts.ipv4_address}"
}

output "web_ui_url" {
  description = "OpenTAKServer Web UI"
  value       = "https://${digitalocean_droplet.fts.ipv4_address}"
}

output "ssl_cot_url" {
  description = "SSL CoT endpoint (for ATAK/iTAK)"
  value       = "${digitalocean_droplet.fts.ipv4_address}:8089"
}

output "cert_enrollment_url" {
  description = "Certificate enrollment endpoint"
  value       = "https://${digitalocean_droplet.fts.ipv4_address}:8446"
}

output "truststore_url" {
  description = "Download truststore for client enrollment"
  value       = "https://${digitalocean_droplet.fts.ipv4_address}/api/truststore"
}

output "install_log_command" {
  description = "Command to check OTS installation progress"
  value       = "ssh root@${digitalocean_droplet.fts.ipv4_address} 'tail -f /var/log/ots-install.log'"
}
