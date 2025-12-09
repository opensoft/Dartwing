# ADB Service Container
# Provides centralized ADB server for multiple Flutter/Android app containers
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK Command Line Tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin

# Create Android SDK directory
RUN mkdir -p $ANDROID_SDK_ROOT

# Download and install Android SDK Command Line Tools
RUN curl -o /tmp/commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip /tmp/commandlinetools.zip -d /tmp && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    mv /tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest/ && \
    rm -rf /tmp/commandlinetools.zip /tmp/cmdline-tools

# Install platform-tools (includes ADB)
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools"

# Create startup script
RUN mkdir -p /scripts
COPY adb-service-start.sh /scripts/adb-service-start.sh
RUN chmod +x /scripts/adb-service-start.sh

# Expose ADB server port
EXPOSE 5037

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD adb devices > /dev/null || exit 1

# Run ADB service
CMD ["/scripts/adb-service-start.sh"]