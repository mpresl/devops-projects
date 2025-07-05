#!/bin/bash

echo "==================== Server Stats ===================="

# OS Version
echo -e "\n>> OS Version:"
cat /etc/os-release | grep -E "^(NAME|VERSION)" | sed 's/"/ /g' | sed 's/=/ : /'

# System Uptime
echo -e "\n>> System Uptime:"
uptime

# Load Average
echo -e "\n>> Load Average:"
uptime | awk -F'load average:' '{print $2}' | awk '{printf "1 min: %s, 5 min: %s, 15 min: %s\n", $1, $2, $3}'

# Logged in Users
echo -e "\n>> Currently Logged in Users:"
who | wc -l | awk '{printf "Total users logged in: %d\n", $1}'
echo "User sessions:"
who

# Failed Login Attempts (last 24 hours)
echo -e "\n>> Failed Login Attempts (Last 24 hours):"
if [ -f /var/log/auth.log ]; then
    failed_attempts=$(grep "Failed password" /var/log/auth.log | grep "$(date '+%b %d')" | wc -l)
    printf "Failed login attempts today: %d\n" $failed_attempts
    echo "Recent failed attempts:"
    grep "Failed password" /var/log/auth.log | grep "$(date '+%b %d')" | tail -5
elif [ -f /var/log/secure ]; then
    failed_attempts=$(grep "Failed password" /var/log/secure | grep "$(date '+%b %d')" | wc -l)
    printf "Failed login attempts today: %d\n" $failed_attempts
    echo "Recent failed attempts:"
    grep "Failed password" /var/log/secure | grep "$(date '+%b %d')" | tail -5
else
    echo "Could not find auth log file (tried /var/log/auth.log and /var/log/secure)"
fi

# CPU Usage
echo -e "\n>> CPU Usage:"
top -bn1 | grep "Cpu(s)" | \
awk '{usage=100 - $8; printf "Total CPU Usage: %.2f%%\n", usage}'

# Memory Usage
echo -e "\n>> Memory Usage:"
free -m | awk 'NR==2{
    used=$3; free=$4; total=$2;
    printf "Used: %d MB, Free: %d MB, Total: %d MB, Usage: %.2f%%\n", used, free, total, used/total * 100
}'

# Disk Usage
echo -e "\n>> Disk Usage:"
df -h --total | grep 'total' | \
awk '{printf "Used: %s, Free: %s, Total: %s, Usage: %s\n", $3, $4, $2, $5}'

# Top 5 processes by CPU usage
echo -e "\n>> Top 5 Processes by CPU Usage:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory usage
echo -e "\n>> Top 5 Processes by Memory Usage:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

echo "======================================================================"
