#!/bin/bash

echo "======================================="
echo "Android Emulator Connection Verification"
echo "======================================="
echo ""

# Check if ADB_SERVER_SOCKET is set
if [ -z "$ADB_SERVER_SOCKET" ]; then
    echo "❌ ADB_SERVER_SOCKET not set. Setting it now..."
    export ADB_SERVER_SOCKET=tcp:host.docker.internal:5037
    echo "✅ ADB_SERVER_SOCKET set to: $ADB_SERVER_SOCKET"
else
    echo "✅ ADB_SERVER_SOCKET is set to: $ADB_SERVER_SOCKET"
fi

echo ""
echo "Checking ADB connection..."

# Check ADB devices
adb_output=$(adb devices -l 2>&1)
if echo "$adb_output" | grep -q "device product:"; then
    echo "✅ ADB devices found:"
    echo "$adb_output"
else
    echo "❌ No Android devices found via ADB"
    echo "ADB output: $adb_output"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Make sure an Android emulator is running on your Windows host"
    echo "2. Run the following on Windows Command Prompt:"
    echo "   cd \"C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\platform-tools\""
    echo "   adb.exe devices"
    echo "   adb.exe -s <emulator-name> tcpip 5555"
    exit 1
fi

echo ""
echo "Checking Flutter device detection..."

# Check Flutter devices
flutter_output=$(flutter devices 2>&1)
if echo "$flutter_output" | grep -q "emulator"; then
    echo "✅ Flutter can detect Android emulator:"
    echo "$flutter_output" | grep -E "(emulator|Android)"
else
    echo "❌ Flutter cannot detect Android emulator"
    echo "Flutter output:"
    echo "$flutter_output"
    exit 1
fi

echo ""
echo "🎉 Success! Your Android emulator connection is working!"
echo ""
echo "You can now:"
echo "1. Run 'flutter run' to deploy to the emulator"
echo "2. Use VS Code tasks to manage emulators"
echo "3. Debug your Flutter apps on the connected emulator"
echo ""