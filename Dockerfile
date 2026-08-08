# Start with the official Kasm Ubuntu Jammy (22.04) desktop
FROM kasmweb/ubuntu-jammy-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 1. Pre-answer Wireshark's hidden prompt
# 2. Update Ubuntu's stable repositories
# 3. Install Wireshark and all core networking tools
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get update && \
    apt-get install -y \
    wireshark \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    tcpdump \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
