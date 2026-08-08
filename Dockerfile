# Start with the official Kasm Kali desktop
FROM kasmweb/kali-rolling-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# Bypass the expired check and ONLY install lightweight CLI networking tools
# Wireshark is removed to prevent dependency conflicts
RUN apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --fix-missing \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    tcpdump \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
