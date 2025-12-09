#!/bin/bash

# Enhanced script for Android emulator control from container
# Uses HTTP requests to communicate with PowerShell server on host

echo "=================================="
echo "Android Emulator Control Script"
echo "=================================="
echo ""

HOST_SERVER="host.docker.internal:8888"

case "$1" in
    "list")
        echo "Requesting AVD list from host..."
        if curl -s -m 5 "http://$HOST_SERVER/list" 2>/dev/null; then
            echo ""
        else
            echo "Could not connect to emulator server on host."
            echo "Please start the PowerShell server on your Windows host:"
            echo "1. Copy /workspace/.devcontainer/emulator-server.ps1 to your Windows machine"
            echo "2. Open PowerShell as Administrator"
            echo "3. Run: .\\emulator-server.ps1 -Action server"
            echo ""
            echo "Alternative: Use manual method with 'start-manual' command"
        fi
        ;;
        
    "start")
        local avd_name="$2"
        if [ -z "$avd_name" ]; then
            echo "Usage: $0 start <avd_name>"
            echo "First, list available AVDs:"
            $0 list
            return 1
        fi
        
        echo "Requesting to start AVD: $avd_name"
        if curl -s -m 10 "http://$HOST_SERVER/start?avd=$avd_name" 2>/dev/null; then
            echo ""
            echo "Start command sent. Waiting for emulator to boot..."
            sleep 5
            $0 connect
        else
            echo "Could not connect to emulator server on host."
            echo "Please ensure the PowerShell server is running."
        fi
        ;;
        
    "stop")
        echo "Requesting to stop all emulators..."
        if curl -s -m 5 "http://$HOST_SERVER/stop" 2>/dev/null; then
            echo ""
            $0 disconnect
        else
            echo "Could not connect to emulator server on host."
        fi
        ;;

    "connect")
        echo "Checking ADB service connection..."
        
        # Check if ADB service is running
        if ! docker ps --filter "name=adb_service" --filter "status=running" | grep -q adb_service; then
            echo "❌ ADB service container is not running"
            echo ""
            echo "The ADB service should start automatically with docker-compose."
            echo "If it's not running, try:"
            echo "   1. Use VS Code task: 'ADB Service: Start/Restart'"
            echo "   2. Or manually: docker-compose -f docker-compose-with-adb.yml up -d adb-service"
            return 1
        fi
        
        echo "✅ ADB service container is running"
        
        # Test network connection to ADB service
        if nc -z adb-service 5037 2>/dev/null; then
            echo "✅ ADB service is reachable on port 5037"
        else
            echo "⚠️  Cannot reach ADB service on port 5037"
            echo "   This might be normal if containers are starting up"
        fi
        
        # Check ADB_SERVER_SOCKET environment variable
        if [ "$ADB_SERVER_SOCKET" = "tcp:adb-service:5037" ]; then
            echo "✅ ADB_SERVER_SOCKET correctly configured: $ADB_SERVER_SOCKET"
        else
            echo "⚠️  ADB_SERVER_SOCKET not set correctly"
            echo "   Current: $ADB_SERVER_SOCKET"
            echo "   Expected: tcp:adb-service:5037"
        fi
        
        # Check ADB service logs for connection status
        echo ""
        echo "📋 ADB Service Status:"
        docker logs adb_service --tail 5 2>/dev/null || echo "   Cannot read ADB service logs"
        
        echo ""
        echo "🚀 Ready to deploy!"
        echo "   The ADB service handles emulator connection automatically."
        echo "   Just run: flutter run"
        ;;
        
    "service-status")
        echo "Checking ADB service container status..."
        
        # Check container status
        if docker ps --filter "name=adb_service" --filter "status=running" | grep -q adb_service; then
            echo "✅ ADB service container is running"
            
            # Test network connectivity
            if nc -z adb-service 5037 2>/dev/null; then
                echo "✅ ADB service is reachable on port 5037"
            else
                echo "⚠️  ADB service not reachable on port 5037"
            fi
        else
            echo "❌ ADB service container is not running"
            echo "   Start with: docker-compose -f docker-compose-with-adb.yml up -d adb-service"
        fi
        
        # Show Docker container details
        echo ""
        echo "Container details:"
        docker ps --filter "name=adb_service" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
        
        # Show recent logs
        echo ""
        echo "Recent ADB service logs:"
        docker logs adb_service --tail 10 2>/dev/null || echo "   Cannot read logs"
        ;;
        
    "service-start")
        echo "Starting ADB service container..."
        docker-compose -f docker-compose-with-adb.yml up -d adb-service
        echo "Waiting for service to be ready..."
        sleep 5
        $0 service-status
        ;;
        
    "service-restart")
        echo "Restarting ADB service container..."
        docker-compose -f docker-compose-with-adb.yml restart adb-service
        echo "Waiting for service to be ready..."
        sleep 5
        $0 service-status
        ;;
        
    "service-stop")
        echo "Stopping ADB service container..."
        docker-compose -f docker-compose-with-adb.yml stop adb-service
        echo "ADB service stopped."
        ;;
        
    "service-logs")
        echo "ADB service logs (last 50 lines):"
        echo "Press Ctrl+C to exit log viewing..."
        docker logs adb_service --tail 50 -f 2>/dev/null || echo "Cannot read ADB service logs"
        
    "status")
        echo "Checking emulator connection status..."
        if command -v adb >/dev/null 2>&1; then
            adb devices -l
        else
            echo "ADB not available. Adding to PATH..."
            export PATH=$PATH:/opt/android-sdk/platform-tools
            adb devices -l
        fi
        ;;
        
    "disconnect")
        echo "Disconnecting from all emulators..."
        adb disconnect
        adb kill-server
        echo "Disconnected."
        ;;
        
    "start-manual")
        echo "To start an emulator on your host Windows machine:"
        echo ""
        echo "Method 1 - Using Android Studio:"
        echo "  1. Open Android Studio"
        echo "  2. Go to Tools > AVD Manager"
        echo "  3. Click 'Play' button next to an AVD"
        echo ""
        echo "Method 2 - Using Command Line:"
        echo "  1. Open Command Prompt or PowerShell"
        echo "  2. Navigate to: C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\emulator"
        echo "  3. Run: emulator.exe -list-avds    (to see available AVDs)"
        echo "  4. Run: emulator.exe -avd <AVD_NAME>"
        echo ""
        echo "Method 3 - Using Windows Run Dialog:"
        echo "  1. Press Win+R"
        echo "  2. Type: C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\emulator\\emulator.exe -avd Pixel_7_API_34"
        echo "  3. Press Enter"
        echo ""
        echo "After starting, run: $0 connect"
        ;;
        
    "install-tasks")
        echo "Installing VS Code tasks for emulator control..."
        # This would be handled by the tasks.json we already created
        echo "Tasks have been added to .vscode/tasks.json"
        echo "Use Ctrl+Shift+P > 'Tasks: Run Task' to access them"
        ;;
        
    *)
        echo "Usage: $0 {connect|service-status|service-start|service-restart|service-stop|service-logs|status|disconnect|start-manual}"
        echo ""
        echo "Connection Commands:"
        echo "  connect         - Check connection to ADB service container"
        echo "  status          - Show connected devices (via ADB service)"
        echo "  disconnect      - Disconnect from all emulators"
        echo ""
        echo "ADB Service Management:"
        echo "  service-status  - Show ADB service container status and logs"
        echo "  service-start   - Start ADB service container"
        echo "  service-restart - Restart ADB service container"
        echo "  service-stop    - Stop ADB service container"
        echo "  service-logs    - View ADB service logs (live)"
        echo ""
        echo "Emulator Setup:"
        echo "  start-manual    - Show instructions to start emulator manually"
        echo ""
        echo "🚀 Automated Architecture:"
        echo "  • ADB service starts automatically with docker-compose"
        echo "  • Just run 'flutter run' - everything is handled automatically!"
        echo "  • Multiple Flutter apps can share the same ADB service"
        echo ""
        echo "🔧 Manual Control (if needed):"
        echo "  • Use service-* commands to manage ADB service manually"
        echo "  • Use VS Code tasks for GUI control"
        ;;
esac