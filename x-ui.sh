#!/bin/bash
# X-UI Management Script - Customized for Hyper-21-stack Repository

# Variables
REPO_URL="https://raw.githubusercontent.com/Hyper-21-stack/x-ui/main/install.sh"
X_UI_BIN="/usr/local/bin/x-ui"

# Functions
install_x_ui() {
    echo "Installing x-ui..."
    bash <(curl -Ls $REPO_URL)
    echo "Installation completed."
}

update_x_ui() {
    echo "Updating x-ui..."
    bash <(curl -Ls $REPO_URL)
    echo "Update completed."
}

start_x_ui() {
    echo "Starting x-ui..."
    systemctl start x-ui
}

stop_x_ui() {
    echo "Stopping x-ui..."
    systemctl stop x-ui
}

restart_x_ui() {
    echo "Restarting x-ui..."
    systemctl restart x-ui
}

status_x_ui() {
    echo "Checking x-ui status..."
    systemctl status x-ui
}

reset_x_ui() {
    echo "Resetting x-ui user credentials..."
    $X_UI_BIN default
}

change_port_x_ui() {
    read -p "Enter new port: " new_port
    $X_UI_BIN set-port $new_port
    systemctl restart x-ui
    echo "Port changed to $new_port."
}

setup_ssl_x_ui() {
    read -p "Enter domain: " domain
    $X_UI_BIN set-cert $domain
    systemctl restart x-ui
    echo "SSL certificate configured for $domain."
}

install_bbr() {
    echo "Installing TCP BBR..."
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo "BBR installation completed."
}

# Menu
echo "Select an option:"
echo "1) Install x-ui"
echo "2) Update x-ui"
echo "3) Start x-ui"
echo "4) Stop x-ui"
echo "5) Restart x-ui"
echo "6) Check status"
echo "7) Reset credentials"
echo "8) Change port"
echo "9) Setup SSL certificate"
echo "10) Install BBR"
echo "0) Exit"
read -p "Enter choice: " choice

case $choice in
    1) install_x_ui ;;
    2) update_x_ui ;;
    3) start_x_ui ;;
    4) stop_x_ui ;;
    5) restart_x_ui ;;
    6) status_x_ui ;;
    7) reset_x_ui ;;
    8) change_port_x_ui ;;
    9) setup_ssl_x_ui ;;
    10) install_bbr ;;
    0) exit 0 ;;
    *) echo "Invalid choice!" ;;
esac
