# Start with the official Kasm Kali desktop
FROM kasmweb/kali-rolling-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions during installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Retrieve the latest security key (using wget to be safe)
# 2. Bypass Kali's expired repository check
# 3. Install core networking tools AND Wireshark
RUN wget -qO /etc/apt/trusted.gpg.d/kali-archive-keyring.gpg https://archive.kali.org/archive-keyring.gpg && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --fix-missing \
    wireshark \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
