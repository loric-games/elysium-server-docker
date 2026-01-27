FROM ubuntu:latest

# Configure Timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Requierments
RUN DEBIAN_FRONTEND=noninteractive; apt-get update && \
	apt-get install -y lib32stdc++6 curl jo gdb && \
	apt-get clean

# setup steam user
RUN useradd -u 1001 -m steam
WORKDIR /home/steam
USER steam

COPY server.sh .

# Download steamcmd
RUN mkdir steamcmd && cd steamcmd && \
    curl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Start steamcmd to force it to update itself
RUN ./steamcmd/steamcmd.sh +quit && \
    mkdir -pv /home/steam/.steam/sdk64/ && \
    ln -s /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# Start the server main script
ENTRYPOINT ["bash", "/home/steam/server.sh"]