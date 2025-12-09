# Dockerfile for packaging Dartwing APKs
# This creates a minimal container image containing the built APK files
# for distribution and deployment purposes

FROM alpine:3.19

# Metadata
LABEL org.opencontainers.image.title="Dartwing APK Package"
LABEL org.opencontainers.image.description="Container image containing Dartwing Android APK builds"
LABEL org.opencontainers.image.vendor="Dartwing Project"
LABEL org.opencontainers.image.source="https://github.com/dartwingers/dartwing"

# Create directory structure for APKs
RUN mkdir -p /apks/debug /apks/release

# Copy APK files from build context
# These will be copied from build/app/outputs/flutter-apk/ during CI
COPY build/app/outputs/flutter-apk/dartwing-debug.apk /apks/debug/
COPY build/app/outputs/flutter-apk/dartwing-release-unsigned.apk /apks/release/

# Add metadata file with build information
RUN echo "Dartwing APK Package" > /apks/README.txt && \
    echo "Built: $(date)" >> /apks/README.txt && \
    echo "" >> /apks/README.txt && \
    echo "Contents:" >> /apks/README.txt && \
    ls -lh /apks/debug/ >> /apks/README.txt 2>/dev/null || echo "  No debug APK" >> /apks/README.txt && \
    ls -lh /apks/release/ >> /apks/README.txt 2>/dev/null || echo "  No release APK" >> /apks/README.txt

# Set working directory
WORKDIR /apks

# Default command shows available APKs
CMD ["sh", "-c", "cat README.txt && echo '' && echo 'APK files available in /apks directory'"]
