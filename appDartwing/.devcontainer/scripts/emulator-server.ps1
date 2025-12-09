# PowerShell script to run on Windows host
# Save this as emulator-server.ps1 on your Windows machine

param(
    [string]$Action = "help",
    [string]$AvdName = ""
)

$EmulatorPath = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
$AdbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

function List-Avds {
    Write-Host "Available AVDs:"
    & $EmulatorPath -list-avds
}

function Start-Emulator {
    param([string]$Name)
    
    if ([string]::IsNullOrEmpty($Name)) {
        Write-Host "Please specify AVD name"
        List-Avds
        return
    }
    
    Write-Host "Starting emulator: $Name"
    Start-Process $EmulatorPath -ArgumentList "-avd", $Name -WindowStyle Normal
    
    # Wait a bit and start ADB server
    Start-Sleep 5
    Write-Host "Starting ADB server..."
    & $AdbPath start-server
}

function Stop-Emulators {
    Write-Host "Stopping all emulators..."
    Get-Process emulator* -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process qemu* -ErrorAction SilentlyContinue | Stop-Process -Force
    & $AdbPath kill-server
}

function Start-Server {
    Write-Host "Starting simple HTTP server for emulator control..."
    Write-Host "This will listen on http://localhost:8888"
    Write-Host "Press Ctrl+C to stop"
    
    # Simple HTTP server using PowerShell
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:8888/")
    $listener.Start()
    
    Write-Host "Server started. Listening for commands..."
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.AbsolutePath
        $query = $request.Url.Query
        
        Write-Host "Received request: $path$query"
        
        $responseText = ""
        
        switch ($path) {
            "/list" {
                $avds = & $EmulatorPath -list-avds
                $responseText = "Available AVDs:`n" + ($avds -join "`n")
            }
            "/start" {
                if ($query -match "avd=([^&]+)") {
                    $avdName = $matches[1]
                    Start-Emulator $avdName
                    $responseText = "Starting emulator: $avdName"
                } else {
                    $responseText = "Missing AVD name. Use: /start?avd=YourAvdName"
                }
            }
            "/stop" {
                Stop-Emulators
                $responseText = "Stopping all emulators"
            }
            default {
                $responseText = "Available endpoints:`n/list - List AVDs`n/start?avd=NAME - Start AVD`n/stop - Stop all emulators"
            }
        }
        
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseText)
        $response.ContentLength64 = $buffer.Length
        $response.ContentType = "text/plain"
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}

switch ($Action.ToLower()) {
    "list" { List-Avds }
    "start" { Start-Emulator $AvdName }
    "stop" { Stop-Emulators }
    "server" { Start-Server }
    default {
        Write-Host "Android Emulator Control Script"
        Write-Host "Usage: .\emulator-server.ps1 -Action <action> [-AvdName <name>]"
        Write-Host ""
        Write-Host "Actions:"
        Write-Host "  list          - List available AVDs"
        Write-Host "  start         - Start emulator (requires -AvdName)"
        Write-Host "  stop          - Stop all emulators"
        Write-Host "  server        - Start HTTP control server"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  .\emulator-server.ps1 -Action list"
        Write-Host "  .\emulator-server.ps1 -Action start -AvdName Pixel_7_API_34"
        Write-Host "  .\emulator-server.ps1 -Action server"
    }
}