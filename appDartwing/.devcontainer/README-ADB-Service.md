# ADB Service Architecture

This setup provides a **centralized ADB service container** that multiple Flutter/Android app containers can share to connect to Android emulators.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DartWing App  │    │   Other Apps    │    │   More Apps     │
│   Container     │    │   Container     │    │   Container     │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     ADB Service           │
                    │     Container             │
                    │   - Runs ADB server       │
                    │   - Exposes port 5037     │
                    │   - Connects to host      │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   Windows Host            │
                    │   - Android Emulator      │
                    │   - Port 5555             │
                    └───────────────────────────┘
```

## Benefits

1. **No Port Conflicts**: Only one ADB server runs (in the service container)
2. **Shared Connection**: Multiple app containers share the same emulator connection
3. **Clean Architecture**: Each app container focuses on its app, not ADB management
4. **Auto-Reconnection**: ADB service automatically reconnects if emulator restarts

## Usage

### 1. Start the services
```bash
docker-compose -f docker-compose-with-adb.yml up -d
```

### 2. Check ADB service status
```bash
# From inside any app container
./.devcontainer/emulator-helper.sh service-status
```

### 3. Check connection
```bash
# From inside any app container  
./.devcontainer/emulator-helper.sh connect
```

### 4. Deploy your app
```bash
flutter run
# The app container automatically uses the ADB service via ADB_SERVER_SOCKET
```

## Environment Variables

Each app container should have:
```bash
ADB_SERVER_SOCKET=tcp:adb-service:5037
```

This tells the app container's Flutter/ADB tools to connect to the ADB service container instead of trying to start their own ADB server.

## For Additional App Containers

To add more Flutter/Android apps that share this ADB service:

1. Add them to the same `docker-compose-with-adb.yml` file
2. Set `ADB_SERVER_SOCKET=tcp:adb-service:5037` in their environment
3. Add `depends_on: adb-service` with health check condition
4. Connect them to the `dartnet` network

## Troubleshooting

### ADB Service Not Reachable
```bash
# Check if ADB service container is running
docker ps --filter "name=adb_service"

# Check ADB service logs
docker logs adb_service

# Restart ADB service
docker-compose -f docker-compose-with-adb.yml restart adb-service
```

### Emulator Not Connected
1. Make sure Android emulator is running on Windows host
2. In emulator, enable network ADB: `adb tcpip 5555`
3. The ADB service will auto-connect every 30 seconds

### Multiple Emulators
The ADB service will automatically connect to any emulator running on the standard port (5555). If you have multiple emulators, they will all be available to all app containers.