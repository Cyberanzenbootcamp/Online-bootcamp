# Start with the official Kasm Kali desktop
FROM kasmweb/kali-rolling-desktop:1.15.0

# Switch to root to install tools
USER root

# Tell the OS not to ask interactive questions
ENV DEBIAN_FRONTEND=noninteractive

# 1. Retrieve the latest key using curl (lowercase -o)
# 2. Pre-answer Wireshark's hidden background prompt
# 3. Bypass Kali's strict expired repository check
# 4. Install the tools and auto-fix any missing dependencies
RUN curl -sL https://archive.kali.org/archive-keyring.gpg -o /usr/share/keyrings/kali-archive-keyring.gpg && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
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
