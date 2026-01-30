FROM ubuntu:latest

# Install Requirements
RUN DEBIAN_FRONTEND=noninteractive; apt-get update && \
    apt-get install -y lib32stdc++6 curl jo gdb locales && \
    apt-get clean

# Configure Locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Setup steam user
RUN useradd -u 1001 -m steam
WORKDIR /home/steam
USER steam

# Download steamcmd
RUN mkdir steamcmd && cd steamcmd && \
    curl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Initialize steamcmd
RUN ./steamcmd/steamcmd.sh +quit && \
    mkdir -pv /home/steam/.steam/sdk64/ && \
    ln -s /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# Pre-create elysium directory with correct permissions
RUN mkdir -p /home/steam/elysium && \
    chown -R steam:steam /home/steam/elysium

# Default command
CMD ["bash", "/home/steam/server.sh"]