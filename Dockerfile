# 1. We MUST use Ubuntu to avoid the expired Kali server crashes
FROM kasmweb/ubuntu-jammy-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 2. Pure, clean update and installation of only basic networking tools
RUN apt-get update && \
    apt-get install -y \
    nmap \
    iputils-ping \
    net-tools \
    dnsutils \
    tcpdump \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
