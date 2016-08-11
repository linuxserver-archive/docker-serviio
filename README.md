![https://linuxserver.io](https://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io](https://forum.linuxserver.io)
* [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`
* [Podcast](https://www.linuxserver.io/index.php/category/podcast/) covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# lsiodev/serviio

Serviio is a free media server. It allows you to stream your media files (music, video or images) to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected home network. [Serviio](http://serviio.org/)

## Usage

```
docker create --name=serviio 
-v /etc/localtime:/etc/localtime:ro \
-v <path to data>:/config \
-v <path to media>:/media \
-v <path for transcoding>:/tmp \
-e PGID=<gid> -e PUID=<uid> \
--net=host lsiodev/serviio
```

**Parameters**

* `net=host` - Set network type
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` - Where serviio stores its configuration files etc.
* `-v /media` - Path to your media files, add more as necessary, see below.
* `-v /tmp` - Temp folder - see below. -*optional, but recommended*
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation

It is based on ubuntu xenial with s6 overlay, for shell access whilst the container is running do `docker exec -it serviio /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

The webui is at <your-ip>:23423/console. Add as many media folder mappings as required with `-v /media/tv-shows` etc... Also setting a mapping for transcoding `-v /tmp`  ensures that the container doesn't grow unneccesarily large.

## Info

* Shell access whilst the container is running: `docker exec -it serviio /bin/bash`
* To monitor the logs of the container in realtime `docker logs -f serviio`.

## Versions

+ **11-08-16:** Rebase to xenial.
+ **21-01-16:** Ver 1.6 , webui built in.
+ **11.12.15:** Initial Release.

