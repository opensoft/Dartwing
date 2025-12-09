#!/bin/bash

echo "========================================="
echo "Starting ADB Service Container"
echo "========================================="

# Start ADB server to listen on all interfaces
echo "Starting ADB server on 0.0.0.0:5037..."
adb -a -P 5037 server nodaemon &
ADB_PID=$!

# Wait for ADB server to start
sleep 3

# Function to connect to host emulator
connect_to_emulator() {
    echo "Attempting to connect to host emulator..."
    
    # Try to connect to emulator on host
    echo "Connecting to host.docker.internal:5555..."
    adb connect host.docker.internal:5555
    
    # Show connected devices
    echo "Connected devices:"
    adb devices -l
    
    # If no devices connected, show help
    if ! adb devices | grep -q "device$"; then
        echo ""
        echo "⚠️  No emulator connected yet."
        echo "To connect an emulator:"
        echo "  1. Start Android emulator on Windows"
        echo "  2. In emulator console: adb tcpip 5555"
        echo "  3. ADB service will auto-connect every 30 seconds"
    else
        echo "✅ Emulator connected successfully!"
    fi
}

# Initial connection attempt
connect_to_emulator

# Keep trying to connect every 30 seconds
while true; do
    sleep 30
    
    # Check if emulator is still connected
    if ! adb devices | grep -q "device$"; then
        echo "$(date): No emulator connected, trying to reconnect..."
        connect_to_emulator
    else
        echo "$(date): Emulator still connected ✅"
    fi
done

# Wait for ADB server process
wait $ADB_PID