#!/bin/bash

# Script to start Android emulator on Windows host from container
# This script communicates with the host through various methods

HOST_EMULATOR_PATH="C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\emulator\\emulator.exe"
HOST_SDK_PATH="C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk"

# Function to list available AVDs on host
list_avds() {
    echo "Listing available AVDs on host..."
    
    # Method 1: Try using mounted Windows emulator (if available through WSL)
    if command -v cmd.exe >/dev/null 2>&1; then
        echo "Using WSL integration..."
        cmd.exe /c "$HOST_EMULATOR_PATH -list-avds" 2>/dev/null
    elif command -v powershell.exe >/dev/null 2>&1; then
        echo "Using PowerShell..."
        powershell.exe -Command "& '$HOST_EMULATOR_PATH' -list-avds" 2>/dev/null
    else
        echo "Could not find Windows command interface."
        echo "Available methods to list AVDs:"
        echo "1. Check your host Windows machine manually"
        echo "2. Common AVD names: Pixel_7_API_34, Pixel_4_API_30, etc."
        echo ""
        echo "To create AVDs on host, run Android Studio and use AVD Manager"
    fi
}

# Function to start specific AVD
start_avd() {
    local avd_name="$1"
    if [ -z "$avd_name" ]; then
        echo "Usage: start_avd <avd_name>"
        echo "Available AVDs:"
        list_avds
        return 1
    fi
    
    echo "Starting AVD: $avd_name on host..."
    
    # Method 1: Try WSL integration
    if command -v cmd.exe >/dev/null 2>&1; then
        echo "Using WSL to start emulator..."
        cmd.exe /c "start /B $HOST_EMULATOR_PATH -avd $avd_name" &
    elif command -v powershell.exe >/dev/null 2>&1; then
        echo "Using PowerShell to start emulator..."
        powershell.exe -Command "Start-Process '$HOST_EMULATOR_PATH' -ArgumentList '-avd $avd_name' -WindowStyle Normal" &
    else
        echo "Cannot directly start emulator from container."
        echo "Please manually start the emulator on your host:"
        echo ""
        echo "1. Open Command Prompt or PowerShell on Windows"
        echo "2. Run: cd \"$HOST_SDK_PATH\\emulator\""
        echo "3. Run: emulator.exe -avd $avd_name"
        echo ""
        echo "Then this script will try to connect via ADB..."
    fi
    
    echo "Emulator start command sent. Waiting for emulator to boot..."
    
    # Wait and try to connect ADB
    echo "Attempting to connect ADB in 10 seconds..."
    sleep 10
    
    # Try to connect to emulator via ADB
    if command -v adb >/dev/null 2>&1; then
        echo "Connecting to emulator via ADB..."
        adb connect host.docker.internal:5555 || adb connect localhost:5555 || echo "ADB connection will be available once emulator is fully started"
        adb devices
    else
        echo "ADB not available in container. Please ensure platform-tools are in PATH."
    fi
}

# Function to kill emulators on host
kill_emulators() {
    echo "Killing emulators on host..."
    
    if command -v cmd.exe >/dev/null 2>&1; then
        echo "Using WSL to kill emulators..."
        cmd.exe /c "taskkill /f /im emulator.exe" 2>/dev/null || echo "No emulator processes found"
        cmd.exe /c "taskkill /f /im qemu-system-*" 2>/dev/null || echo "No QEMU processes found"
    elif command -v powershell.exe >/dev/null 2>&1; then
        echo "Using PowerShell to kill emulators..."
        powershell.exe -Command "Get-Process emulator* | Stop-Process -Force" 2>/dev/null || echo "No emulator processes found"
        powershell.exe -Command "Get-Process qemu* | Stop-Process -Force" 2>/dev/null || echo "No QEMU processes found"
    else
        echo "Cannot kill emulators from container."
        echo "Please manually kill emulator processes on your host:"
        echo "1. Open Task Manager on Windows"
        echo "2. End 'emulator.exe' and 'qemu-system-*' processes"
        echo "Or run in Command Prompt: taskkill /f /im emulator.exe"
    fi
    
    # Also disconnect ADB
    if command -v adb >/dev/null 2>&1; then
        echo "Disconnecting ADB..."
        adb disconnect
        adb kill-server
    fi
}

# Main script logic
case "$1" in
    "list")
        list_avds
        ;;
    "start")
        start_avd "$2"
        ;;
    "kill")
        kill_emulators
        ;;
    *)
        echo "Usage: $0 {list|start <avd_name>|kill}"
        echo "Examples:"
        echo "  $0 list                    # List available AVDs"
        echo "  $0 start Pixel_7_API_34    # Start specific AVD"
        echo "  $0 kill                    # Kill all emulators"
        ;;
esac