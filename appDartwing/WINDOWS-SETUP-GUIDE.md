# Windows 11 Setup Guide for Hybrid Flutter Development

```

### 5. **Install VS Code** 💻et environment variables (add to system PATH)
$env:ANDROID_HOME = "C:\Program Files\Android"
$env:PATH += ";C:\Program Files\Android\cmdline-tools\latest\bin;C:\Program Files\Android\platform-tools;C:\Program Files\Android\emulator"elps you set up a fresh Windows 11 machine to work with the containerized Flutter development environment that connects to Windows host emulators.

## 🎯 **Overview**

This setup creates a hybrid development environment where:

- **Windows Host**: Runs Android emulators (better performance, GPU acceleration)
- **WSL2 Container**: Runs Flutter development tools, VS Code, and build processes
- **Network Bridge**: ADB connection between container and Windows emulators

---

## 📋 **Required Software Installation**

### 1. **Enable WSL2** ⚡

```powershell
# Run in PowerShell as Administrator
wsl --install
# Reboot when prompted
```

### 2. **Install Docker Desktop** 🐳

- Download from: <https://www.docker.com/products/docker-desktop/>
- **Important**: Ensure "Use WSL 2 based engine" is enabled in Docker settings
- Enable WSL2 integration for your Linux distribution

### 3. **Install Android SDK Command Line Tools** 📱

```powershell
# Create Android SDK directory
mkdir "C:\Program Files\Android"
cd "C:\Program Files\Android"

# Download command line tools
# Visit: https://developer.android.com/studio#command-tools
# Download commandlinetools-win-*_latest.zip

# Extract to C:\Program Files\Android\cmdline-tools\latest\
```

**## Directory structure should be:

```
C:\Program Files\Android\
├── cmdline-tools\
│   └── latest\
│       ├── bin\
│       ├── lib\
│       └── ...
```**

```

C:\Android\Sdk\
├── cmdline-tools\
│   └── latest\
│       ├── bin\
│       ├── lib\
│       └── ...

```

### 4. **Install Android Emulator & System Images** 🔧

**Run these commands in Windows PowerShell (Administrator privileges NOT required):**

```powershell
# Set environment variables for this session
$env:ANDROID_HOME = "C:\Program Files\Android"
$env:PATH += ";C:\Program Files\Android\cmdline-tools\latest\bin;C:\Program Files\Android\platform-tools;C:\Program Files\Android\emulator"

# Accept Android SDK licenses (interactive - you'll need to type 'y' for each license)
sdkmanager --licenses

# Install essential Android components
sdkmanager "platform-tools" "emulator" "platforms;android-34" "build-tools;34.0.0"

# Install system images for emulator
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create AVD (Android Virtual Device)
avdmanager create avd -n "Pixel_7_API_34" -k "system-images;android-34;google_apis;x86_64" -d "pixel_7"
```

### 5. **Install VS Code** 💻

- Download from: <https://code.visualstudio.com/>
- Install the **Remote - Containers** extension
- Install the **WSL** extension

### 6. **Install Node.js** 🟢

- Download from: <https://nodejs.org/> (LTS version recommended)
- Use default settings during installation
- This is required for the DevContainer CLI

### 7. **Install DevContainer CLI** 📦

```powershell
# Run in PowerShell (Administrator NOT required)
npm install -g @devcontainers/cli

# Verify installation
devcontainer --version
```

**Why this is needed:** The DevContainer CLI enables:
- Consistent container builds across different environments
- Proper integration with VS Code DevContainer features
- Enhanced Warp workflow automation
- Better container lifecycle management

### 8. **Install Git** 🔄

- Download from: <https://git-scm.com/download/win>
- Use default settings during installation

---

## ⚙️ **Windows Environment Configuration**

### 1. **Set System Environment Variables**

Add these to your **System Environment Variables** (not user variables):

```
ANDROID_HOME = C:\Program Files\Android
ANDROID_SDK_ROOT = C:\Program Files\Android
```

Update **PATH** to include:

```
C:\Program Files\Android\cmdline-tools\latest\bin
C:\Program Files\Android\platform-tools
C:\Program Files\Android\emulator
```

### 2. **Configure BIOS Virtualization Settings** 🔧

**⚠️ CRITICAL: Must be done BEFORE enabling Windows features**

#### **Intel Processors:**

Enter BIOS/UEFI settings and enable:

- **Intel VT-x** (Intel Virtualization Technology)
- **Intel VT-d** (Intel VT for Directed I/O) - if available
- **TPM 2.0** (if available)

Common BIOS menu locations:

- Advanced → CPU Configuration → Intel Virtualization Technology
- Security → Intel TXT → Intel VT-x
- Advanced → Chipset Configuration → Intel VT-d

#### **AMD Processors:**

Enter BIOS/UEFI settings and enable:

- **AMD SVM** (Secure Virtual Machine) - this is what you changed!
- **AMD-V** (AMD Virtualization)
- **IOMMU** (Input-Output Memory Management Unit) - if available
- **TPM 2.0** (if available)

Common BIOS menu locations:

- Advanced → CPU Configuration → AMD SVM Mode
- Advanced → AMD CBS → CPU Common Options → SVM Mode
- Security → AMD Memory Guard → SVM

#### **How to Access BIOS:**

```
1. Restart computer
2. Press key during boot: F2, F12, Del, or Esc (varies by manufacturer)
3. Look for "Virtualization", "SVM", "VT-x", or "CPU" sections
4. Enable virtualization features
5. Save & Exit (usually F10)
6. Windows will restart
```

### 3. **Enable Hyper-V and Windows Hypervisor Platform**

```powershell
# Run as Administrator (AFTER BIOS changes)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All
# Reboot when prompted
```

### 3. **Configure Windows Defender Firewall** 🔥

Allow ADB server connections:

```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "Android ADB Server" -Direction Inbound -Protocol TCP -LocalPort 5037 -Action Allow
```

---

## 🚀 **Project Setup**

### 1. **Clone the Flutter Project**

```bash
# In WSL2 terminal, create projects directory if it doesn't exist
mkdir -p ~/projects
cd ~/projects

# Create dartwing folder and clone into it
mkdir dartwing
git clone <your-dartwing-repository-url> dartwing
cd dartwing
```

### 2. **Open in VS Code Container**

```bash
# In WSL2, from project directory
code .
# VS Code will detect the devcontainer and prompt to reopen in container
# Click "Reopen in Container"
```

### 3. **Start Windows ADB Server** 🔗

```powershell
# In Windows PowerShell
cd "C:\Program Files\Android\platform-tools"
.\adb.exe start-server
```

### 4. **Start Android Emulator** 📱

```powershell
# List available AVDs
emulator -list-avds

# Start emulator (replace with your AVD name)
emulator -avd Pixel_7_API_34
```

---

## 🧪 **Verification Steps**

### 1. **Verify Container Connection**

In the VS Code container terminal:

```bash
# Check Flutter installation
flutter doctor -v

# Check connected devices (should show Windows emulator)
flutter devices

# Verify ADB connection
adb devices
```

### 2. **Test Flutter App**

```bash
# Run the app on emulator
flutter run -d emulator-5556
```

---

## 📝 **Additional Emulator Configuration**

### Creating Multiple AVDs for Testing

```powershell
# Different Android versions
sdkmanager "system-images;android-33;google_apis;x86_64"
sdkmanager "system-images;android-35;google_apis;x86_64"

# Create AVDs
avdmanager create avd -n "Pixel_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel"
avdmanager create avd -n "Pixel_API_35" -k "system-images;android-35;google_apis;x86_64" -d "pixel"
```

### Emulator Performance Optimization

```powershell
# Start emulator with performance flags
emulator -avd Pixel_7_API_34 -gpu host -skin 1080x1920 -memory 4096
```

---

## 🛠 **Troubleshooting**

### Common Issues & Solutions

**1. "adb server out of date" error:**

```powershell
# In Windows
adb kill-server
adb start-server
```

**2. Container can't connect to Windows emulator:**

- Ensure Windows ADB server is running
- Check firewall settings (port 5037)
- Verify Docker Desktop WSL2 integration

**3. Emulator won't start:**

- **First**: Check BIOS virtualization settings (see BIOS section above)
  - Intel: Enable VT-x and VT-d
  - AMD: Enable SVM (Secure Virtual Machine)
- Enable Hyper-V and Windows Hypervisor Platform
- Ensure sufficient RAM allocation (4GB+ recommended)
- Verify Windows Hypervisor Platform is enabled: `bcdedit /enum | findstr hypervisorlaunchtype`

**4. VS Code container fails to build:**

- Ensure Docker Desktop is running
- Check WSL2 integration settings
- Restart Docker Desktop

---

## 🎯 **Quick Start Commands Summary**

**Windows Setup (One-time):**

```powershell
# Start ADB server
cd "C:\Program Files\Android\platform-tools" && .\adb.exe start-server

# Start emulator
emulator -avd Pixel_7_API_34
```

**Container Development:**

```bash
# Verify setup
flutter doctor -v && flutter devices

# Run app
flutter run -d emulator-5556
```

---

## 📚 **Optional: Advanced Tools**

### Android Studio (Optional but Recommended)

- Provides AVD Manager GUI
- Better emulator management
- Download from: <https://developer.android.com/studio>

### Scrcpy (Optional - Screen Mirroring)

```powershell
# Install via chocolatey
choco install scrcpy
# Mirror emulator screen to Windows
scrcpy
```

---

## ✅ **Verification Checklist**

- [ ] WSL2 enabled and working
- [ ] Docker Desktop installed with WSL2 integration
- [ ] Android SDK command line tools installed
- [ ] Android emulator installed and AVD created
- [ ] Environment variables set (ANDROID_HOME, PATH)
- [ ] Firewall rule for ADB (port 5037)
- [ ] VS Code with Remote-Containers extension
- [ ] Node.js installed
- [ ] **DevContainer CLI installed** (`devcontainer --version` works)
- [ ] Git installed
- [ ] Flutter project cloned
- [ ] Container builds and connects to emulator
- [ ] Flutter app runs successfully

---

**🎉 Once all steps are complete, you'll have a fully functional hybrid Flutter development environment with Windows emulator performance and Linux development tools!**
