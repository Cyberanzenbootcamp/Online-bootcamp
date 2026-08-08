# Start with the official Kasm Ubuntu Jammy (22.04) desktop
FROM kasmweb/ubuntu-jammy-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 1. DELETE all third-party repositories (Google, Brave, etc.) that cause crashes
# 2. Update ONLY the stable main Ubuntu servers
# 3. Install core networking tools
RUN rm -rf /etc/apt/sources.list.d/* && \
    apt-get update && \
    apt-get install -y \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    tcpdump \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
