# Elysium Server Docker Image
This repository provides an example on how to setup an Echoes of Elysium standalone server using Docker.

## Configuration

### Environment Variables

Variable | Default | Description
------------ | ------------ | -------------
SERVER_NAME | | The name listed in the server browser
SERVER_ADDR | 0.0.0.0 | The address that the server will bind to
SERVER_PORT | 27015 | The port that the server will listen on
SERVER_DATA | ./GameData | The directory that contains the game data
SERVER_WORLD | ./world | The directory that the server will save the world to
SERVER_LOGS | ./logs | The directory that the server will save logs
SERVER_PASSWORD | empty string | Password for the server
SERVER_PROFILE_ENABLED | false | Should runtime profile logging be enaled
SERVER_SAVE_FREQUENCY | 5 | Specifies how frequently, in minutes, the server saves the world state
SERVER_BACKUPS_ENABLED | true | Should data backups be enabled
SERVER_BACKUPS_FREQUENCY | 30 | Specifies how frequently, in minutes, a backup is created
SERVER_MAX_BACKUPS | 5 | Specifies the maximum number backups to retain
STEAM_CHANNEL | internal | Specifies the Steam patch channel to use

### Network Setup

* The server runs on 2 ports, they are sequential to the supplied SERVER_PORT.
* All 2 of these ports communicate using UDP
* SERVER_PORT+1 is the port that listens for new connections

If you set your `SERVER_PORT=27015`, this mean you will be using ports 27015 and 27016; and your server will be listening on port 27015.

### Volumes

For data persistence you can mount a volume that is used by the Elysium server. All server data is saved in the directory location defined by SERVER_WORLD. When invoking docker you can use the `-v` parameter to specify a volume mount from your host machine to the location defined by SERVER_WORLD.
```
mkdir /host/path/to/elysium-world
docker run -d \
	-e SERVER_WORLD="./world" \
	-v /host/path/to/elysium-world:/home/steam/elysium/server/world
```

## Example

```
# Build the docker image
docker build -t elysium .

# Run a docker image
mkdir ~/elysium-world
docker run -d --name=elysium-test \
	-v ~/elysium-world:/home/steam/elysium/server/world
	-p 27015:27015/udp \
	-p 27016:27016/udp \
	-e SERVER_NAME="My Test Server" \
	elysium:latest
```


asdfasf