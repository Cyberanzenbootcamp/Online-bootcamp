# Start with the official Kasm Kali desktop
FROM kasmweb/kali-rolling-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 1. Pre-answer Wireshark's hidden background prompt
# 2. Bypass Kali's strict expired repository check
# 3. Install the tools and auto-fix any missing dependencies
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --fix-missing \
    nmap \
    wireshark \
    burpsuite \
    metasploit-framework \
    sqlmap \
    hydra \
    john \
    aircrack-ng \
    && apt-get clean

# Switch back to the standard Kasm user for streaming
USER 1000
