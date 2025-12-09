#!/bin/bash

# WSL2 to Windows Android Emulator Connection Script

echo "=================================="
echo "WSL2 → Windows Emulator Connection"
echo "=================================="
echo ""

# First, we need to enable network ADB on the Windows emulator
echo "Step 1: Enable network ADB on your Windows emulator"
echo "Run this command in Windows Command Prompt (as Administrator):"
echo ""
echo "cd \"C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\platform-tools\""
echo "adb.exe tcpip 5555"
echo ""
echo "This enables network ADB on port 5555"
echo ""

# Try different connection methods
echo "Step 2: Trying to connect from WSL2 container..."

# Method 1: Try host.docker.internal (Docker Desktop)
echo "Trying host.docker.internal:5555..."
if adb connect host.docker.internal:5555; then
    echo "✓ Connected via host.docker.internal"
else
    echo "✗ Failed via host.docker.internal"
fi

# Method 2: Try the Docker gateway
echo "Trying 172.17.0.1:5555..."
if adb connect 172.17.0.1:5555; then
    echo "✓ Connected via Docker gateway"
else
    echo "✗ Failed via Docker gateway"
fi

# Method 3: Try common WSL2 Windows host IPs
WSL2_WINDOWS_IPS=("192.168.65.2" "192.168.1.1" "10.0.2.2")

for ip in "${WSL2_WINDOWS_IPS[@]}"; do
    echo "Trying $ip:5555..."
    if adb connect $ip:5555; then
        echo "✓ Connected via $ip"
        break
    else
        echo "✗ Failed via $ip"
    fi
done

echo ""
echo "Current ADB devices:"
adb devices -l

echo ""
echo "If none of the above worked, try these manual steps:"
echo ""
echo "1. On Windows, find your WSL2 IP:"
echo "   In PowerShell: Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match 'WSL'}"
echo ""
echo "2. Or find Windows IP from WSL2:"
echo "   In WSL: cat /etc/resolv.conf (look for nameserver)"
echo ""
echo "3. Ensure Windows Firewall allows ADB port 5555"
echo "4. Make sure emulator is running with network ADB enabled"