#!/bin/bash

LOG_FILE="/var/log/v2ray_install.log"
V2RAY_CONFIG="/etc/v2ray/config.json"
DOMAIN=""
CERT_PATH="/etc/v2ray/cert.pem"
KEY_PATH="/etc/v2ray/key.pem"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Install dependencies
install_dependencies() {
    log "Installing dependencies..."
    apt update -y && apt install -y curl socat jq ufw || { log "Failed to install dependencies."; exit 1; }
}

# Install acme.sh for SSL certificate
install_acme() {
    log "Installing acme.sh..."
    curl https://get.acme.sh | sh
    source ~/.acme.sh/acme.sh.env
}

# Issue SSL certificate
issue_ssl_certificate() {
    local domain="$1"
    log "Issuing SSL certificate for $domain..."
    
    ~/.acme.sh/acme.sh --register-account -m your-email@example.com
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --key-file "$KEY_PATH" --fullchain-file "$CERT_PATH" --force

    if [[ -f "$CERT_PATH" && -f "$KEY_PATH" ]]; then
        log "SSL certificate successfully issued!"
    else
        log "Failed to issue SSL certificate!"
        exit 1
    fi
}

# Install V2Ray
install_v2ray() {
    log "Installing V2Ray..."
    bash <(curl -Ls https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) || {
        log "Failed to install V2Ray."
        exit 1
    }
    log "V2Ray installed successfully!"
}

# Generate UUID
generate_uuid() {
    log "Generating a UUID for V2Ray..."
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "$UUID"
}

# Configure V2Ray with TLS
configure_v2ray() {
    local uuid="$1"
    local port="$2"
    local domain="$3"

    log "Configuring V2Ray with TLS..."
    
    cat > $V2RAY_CONFIG <<EOF
{
  "inbounds": [{
    "port": $port,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "$uuid",
        "alterId": 0
      }]
    },
    "streamSettings": {
      "network": "ws",
      "security": "tls",
      "tlsSettings": {
        "certificates": [{
          "certificateFile": "$CERT_PATH",
          "keyFile": "$KEY_PATH"
        }]
      },
      "wsSettings": {
        "path": "/v2ray"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

    log "V2Ray configuration updated with TLS."
}

# Setup firewall
setup_firewall() {
    local port="$1"
    log "Setting up firewall rules..."
    ufw allow "$port"/tcp
    ufw allow "$port"/udp
    log "Firewall rules updated."
}

# Restart V2Ray service
restart_v2ray() {
    log "Restarting V2Ray service..."
    systemctl restart v2ray || { log "Failed to restart V2Ray service."; exit 1; }
    systemctl enable v2ray
    log "V2Ray service restarted successfully."
}

# Main execution
log "V2Ray Installer with TLS Started"

install_dependencies
install_acme

read -p "Enter your domain name (e.g., example.com): " DOMAIN
if [[ -z "$DOMAIN" ]]; then
    log "Domain is required for TLS setup!"
    exit 1
fi

issue_ssl_certificate "$DOMAIN"
install_v2ray

UUID=$(generate_uuid)
read -p "Enter V2Ray port (default: 443): " PORT
PORT=${PORT:-443}

configure_v2ray "$UUID" "$PORT" "$DOMAIN"
setup_firewall "$PORT"
restart_v2ray

log "V2Ray Installation Completed Successfully with TLS!"
log "Your UUID: $UUID"
log "Port: $PORT"
log "Domain: $DOMAIN"
log "TLS Enabled: Yes"

echo "V2Ray installed with TLS successfully!"
echo "UUID: $UUID"
echo "Port: $PORT"
echo "Domain: $DOMAIN"
echo "TLS Enabled: Yes"
