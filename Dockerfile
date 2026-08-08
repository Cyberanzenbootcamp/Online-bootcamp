# Start with the official Kasm Kali desktop
FROM kasmweb/kali-rolling-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 1. Clean the completely broken APT cache
# 2. Setup the new keyring directory
# 3. Download and dearmor the latest official Kali signing key
# 4. Overwrite the broken sources.list with the modern signed-by format
# 5. Pre-answer Wireshark's hidden prompt
# 6. Update and install Wireshark + networking tools
RUN rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /etc/apt/keyrings/kali-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --fix-missing \
    wireshark \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
