![http://linuxserver.io](http://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://www.linuxserver.io/) team brings you another quality container release featuring dependency update on startup, easy user mapping and community support. Be sure to checkout our [forums](https://forum.linuxserver.io/index.php) or for real-time support our [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`.

# linuxserver/serviio

Serviio is a free media server. It allows you to stream your media files (music, video or images) to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected home network. [Serviio](http://serviio.org/)

## Usage

```
docker create --name=serviio -v /etc/localtime:/etc/localtime:ro -v <path to data>:/config -v <path to media>:/media -v <path for transcoding>:/tmp -e PGID=<gid> -e PUID=<uid>  -p 8780:8780 -p 8895:8895 -p 1900:1900/udp -p 23424:23424 linuxserver/serviio
```

**Parameters**

* `-p 8780` - the port(s)
* `-p 8895` - the port(s)
* `-p 1900/udp` - the port(s)
* `-p 23424` - the port(s)
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` - Where serviio stores its configuration files etc.
* `-v /media` - Path to your media files, add more as necessary, see below.
* `-v /tmp` - Temp folder - see below. -*optional, but recommended*
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` for timezone information eg Europe/London, etc

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it serviio /bin/bash`.

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes our containers work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So we added this feature to let you easily choose when running your containers.

## Setting up the application

The webui is on port 8780. Add as many media folder mappings as required with `-v /media/tv-shows` etc... Also you can setting a mapping for transcoding `-v /tmp`  ensures that the container doesn't grow unneccesarily large.


## Updates

* To update the dependencies `docker restart serviio`.
* To monitor the logs of the container in realtime `docker logs -f serviio`.



## Versions

+ **03.11.2015:** Initial Release.

