#!/bin/bash

#Flag variable to control the loop
continue_script=true

#Function to display system information 
system_info() {
echo "System Information:"

echo "Hostname: $(hostname)"
echo "OS Type: $(uname -o)"
echo "Kernel version: $(uname -r)"
echo "System Uptime: $(uptime -p)"
echo "Disk Space on /:"
df -h / | awk 'NR==2 {print $4 " available"}'
echo "Current Logged-In Users: $(who | wc -l)"
echo ""
}

#Function to manage user accounts
manage_user() {
read -p "Enter a username: " username
if id "$username" &>/dev/null; then
echo "User $username exists."
echo "Home Directory: $(eval echo ~$username)"
echo "Shell: $(getent passwd $username | cut -d: -f7)"
else
echo "User $username does not exist."
read -p "Do you want to create the user $username? (y/n): " create_user
if [[ "$create_user" == "y" ]]; then
read -p "Enter a home directory (e.g., /home/$username): " home_dir
read -p "Enter shell (e.g., /bin/bash): " shell
sudo useradd -m -d "$home_dir" -s "$shell" "$username"
echo "User $username create with home directory $home_dir and shell $shell."
elif [[ "$create_user" == "n" ]]; then
echo "User has chosen not to create the user."
else
echo "Invalid input. Please enter 'y' or 'n'."
fi
fi
}

#Function to backup and compress a directory
backup_directory() {
read -p "Enter the directory path to backup: " dir_path
if [[ -d "$dir_path" ]]; then
tarball_name="/tmp/$(basename "$dir_path")_backup_$(date +%F).tar.gz"
tar -czf "$tarball_name" -C "$dir_path" .
echo "Backup of $dir_path created at $tarball_name."
else
echo "Directory $dir_path does not exist."
fi
}

#Function to manage services
manage_service() {
read -p "Enter the service name: " service_name
if systemctl is-active --quiet "$service_name"; then
echo "Service $service_name is already running."
read -p "Do you want to stop or restart the service? (stop/restart): " action
if [[ "$action" == "stop" ]]; then
if sudo systemctl stop "$service_name"; then
echo "Service $service_name stopped successfully."
else
echo "Failed to stop service $service_name."
fi
elif [[ "$action" == "restart" ]]; then
if sudo systemctl restart "$service_name"; then
echo "Service $service_name restarted successfully."
else
echo "Failed to restart service $service_name."
fi
else
echo "Invalid action. Please 'stop' or 'restart'."
fi
else
echo "Service $service_name is not running."
read -p "Do you want to start the service? (y/n): " start_service
if [[ "$start_service" == "y" ]]; then
if sudo systemctl start "$service_name"; then
echo "Service $service_name started successfully."
else
echo "Failed to start service $service_name."
fi
else
echo "Service start skipped."
fi
fi
}

#Function to display the main menu
show_menu () {
echo "Sysadmin Tool"
echo "1) System Information"
echo "2) Manage Users"
echo "3) Backup Directory"
echo "4) Manage Services"
echo "5) Exit"
}

#Display the menu and handle the user's choice
while $continue_script; do
show_menu
read -p "Choose an option: " choice
case $choice in
1) system_info ;;
2) manage_user ;;
3) backup_directory ;;
4) manage_service ;;
5) echo "Exiting..."; continue_script=false ;;
*) echo "Invalid option. Exiting..."; exit 1 ;;
esac
echo ""
done
