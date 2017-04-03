# openSUSE image supporting systemd

This is the Dockerfile for a Docker image capable of running systemd.

This work is based on [this Fedora](https://github.com/fedora-cloud/Fedora-Dockerfiles/tree/master/systemd/systemd) Dockerfile.

## Building

As usual move into the directory containing this Dockerfile and do:

```
$ docker build -t opensuse/systemd .
```

To run docker in a container you need to mount cgroup file system volume:

```
# docker run --detach --privileged opensuse/systemd
```

To test once inside the container, check and see if systemd is working:

```
# /usr/lib/systemd/systemd --system
```