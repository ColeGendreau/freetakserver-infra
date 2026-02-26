output "droplet_ip" {
  description = "Public IP address of the FreeTAKServer droplet"
  value       = digitalocean_droplet.fts.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${digitalocean_droplet.fts.ipv4_address}"
}

output "fts_cot_url" {
  description = "FreeTAKServer CoT endpoint (for ATAK clients)"
  value       = "${digitalocean_droplet.fts.ipv4_address}:8087"
}

output "fts_ssl_cot_url" {
  description = "FreeTAKServer SSL CoT endpoint"
  value       = "${digitalocean_droplet.fts.ipv4_address}:8089"
}

output "fts_api_url" {
  description = "FreeTAKServer REST API"
  value       = "http://${digitalocean_droplet.fts.ipv4_address}:19023"
}

output "fts_web_ui_url" {
  description = "FreeTAKServer Web UI"
  value       = "http://${digitalocean_droplet.fts.ipv4_address}:5000"
}

output "fts_webmap_url" {
  description = "FreeTAKServer Web Map"
  value       = "http://${digitalocean_droplet.fts.ipv4_address}:8000"
}

output "fts_nodered_url" {
  description = "Node-RED integration server"
  value       = "http://${digitalocean_droplet.fts.ipv4_address}:1880"
}

output "fts_voice_server" {
  description = "Mumble voice server"
  value       = "${digitalocean_droplet.fts.ipv4_address}:64738"
}

output "install_log_command" {
  description = "Command to check FTS installation progress"
  value       = "ssh root@${digitalocean_droplet.fts.ipv4_address} 'tail -f /var/log/fts-install.log'"
}
