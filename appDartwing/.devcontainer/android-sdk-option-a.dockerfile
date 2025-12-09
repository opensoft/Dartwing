# Option A: Complete Android SDK Installation
# Replace the current android-tools line in Dockerfile with this:

# Method 1: Using Ubuntu's android-sdk package
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  android-sdk android-sdk-platform-tools-common \
  android-sdk-build-tools android-sdk-platform-23 \
  && apt-get clean -y

# Method 2: Download and install official Android SDK (preferred)
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
  && unzip -q commandlinetools-linux-11076708_latest.zip -d /opt/android-sdk \
  && rm commandlinetools-linux-11076708_latest.zip \
  && mv /opt/android-sdk/cmdline-tools /opt/android-sdk/cmdline-tools-temp \
  && mkdir -p /opt/android-sdk/cmdline-tools/latest \
  && mv /opt/android-sdk/cmdline-tools-temp/* /opt/android-sdk/cmdline-tools/latest/ \
  && rmdir /opt/android-sdk/cmdline-tools-temp

# Set SDK environment variables to point to /opt/android-sdk
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV PATH="$PATH:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator:/opt/android-sdk/cmdline-tools/latest/bin"

# Accept licenses and install essential components
RUN yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses \
  && /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "emulator" \
  "system-images;android-34;google_apis;x86_64"

# Create a default AVD
RUN echo "no" | /opt/android-sdk/cmdline-tools/latest/bin/avdmanager create avd \
  -n "Container_Pixel_7" \
  -k "system-images;android-34;google_apis;x86_64" \
  --device "pixel_7"