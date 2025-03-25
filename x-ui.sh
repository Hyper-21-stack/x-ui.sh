#!/bin/bash

# Global Variables
LOG_FILE="/var/log/x-ui-install.log"
PORT_MIN=1
PORT_MAX=65535

# Function for logging errors
LOGE() {
    echo "[ERROR] $(date) $1" >> "$LOG_FILE"
}

# Function for logging success
LOGS() {
    echo "[INFO] $(date) $1" >> "$LOG_FILE"
}

# Function to check for root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        LOGE "This script must be run as root"
        exit 1
    fi
}

# Function to check for required dependencies
check_dependencies() {
    LOGS "Checking for required dependencies..."

    # Check if curl is installed
    if ! command -v curl &>/dev/null; then
        LOGE "curl is required but not installed"
        exit 1
    fi

    # Check if systemctl is available (systemd check)
    if ! command -v systemctl &>/dev/null; then
        LOGE "systemd is required but not installed"
        exit 1
    fi

    LOGS "All dependencies are met."
}

# Function to detect the OS
detect_os() {
    LOGS "Detecting operating system..."

    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
    else
        LOGE "Cannot detect the operating system."
        exit 1
    fi

    LOGS "Detected OS: $OS_NAME $OS_VERSION"
}

# Function to handle the port input and validation
set_port() {
    read -p "Enter port number [$PORT_MIN-$PORT_MAX]: " port

    if ! [[ "$port" =~ ^[0-9]+$ ]] || ((port < PORT_MIN || port > PORT_MAX)); then
        LOGE "Invalid port number entered. It should be between $PORT_MIN and $PORT_MAX."
        exit 1
    fi

    LOGS "Using port $port."
}

# Function to install x-ui panel
install() {
    LOGS "Starting installation of x-ui..."

    # Install necessary dependencies
    apt-get update && apt-get install -y curl wget unzip

    # Download the installation script
    curl -sSL https://github.com/vaxilu/x-ui/releases/download/v0.9.1/install.sh -o install.sh

    # Run the installation script
    bash install.sh

    if [ $? -ne 0 ]; then
        LOGE "Installation failed."
        exit 1
    fi

    LOGS "x-ui panel installed successfully."
}

# Function to uninstall x-ui panel
uninstall() {
    LOGS "Uninstalling x-ui panel..."

    # Run uninstall script
    bash /usr/local/x-ui/uninstall.sh

    if [ $? -ne 0 ]; then
        LOGE "Uninstallation failed."
        exit 1
    fi

    LOGS "x-ui panel uninstalled successfully."
}

# Function to update x-ui panel
update() {
    LOGS "Updating x-ui panel..."

    # Download and run update script
    curl -sSL https://github.com/vaxilu/x-ui/releases/latest/download/update.sh -o update.sh
    bash update.sh

    if [ $? -ne 0 ]; then
        LOGE "Update failed."
        exit 1
    fi

    LOGS "x-ui panel updated successfully."
}

# Function to manage SSL certificate issuance
ssl_cert_issue() {
    LOGS "Issuing SSL certificate..."

    # Install acme.sh if not already installed
    if ! command -v acme.sh &>/dev/null; then
        curl https://get.acme.sh | bash
    fi

    # Issue SSL certificate
    ~/.acme.sh/acme.sh --issue -d yourdomain.com --standalone --preferred-chain "ISRG Root X1"

    if [ $? -ne 0 ]; then
        LOGE "SSL certificate issuance failed."
        exit 1
    fi

    LOGS "SSL certificate issued successfully."
}

# Main Menu
main_menu() {
    clear
    echo "Choose an action:"
    echo "1. Install x-ui panel"
    echo "2. Uninstall x-ui panel"
    echo "3. Update x-ui panel"
    echo "4. Issue SSL certificate"
    echo "5. Exit"

    read -p "Select an option (1-5): " choice

    case $choice in
        1) install ;;
        2) uninstall ;;
        3) update ;;
        4) ssl_cert_issue ;;
        5) exit 0 ;;
        *) 
            LOGE "Invalid option selected."
            exit 1
            ;;
    esac
}

# Main script execution
check_root
check_dependencies
detect_os
set_port
main_menu
