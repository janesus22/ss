# [xjasonlyu/jellyfin](https://github.com/xjasonlyu/jellyfin-docker)

[Jellyfin](https://jellyfin.github.io/) is a Free Software Media System that puts you in control of managing and streaming your media. It is an alternative to the proprietary Emby and Plex, to provide media from a dedicated server to end-user devices via multiple apps. Jellyfin is descended from Emby's 3.5.2 release and ported to the .NET Core framework to enable full cross-platform support. There are no strings attached, no premium licenses or features, and no hidden agendas: just a team who want to build something better and work together to achieve it.

[![jellyfin](https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG/banner-logo-solid.svg?sanitize=true)](https://jellyfin.github.io/)

## Diff

When I decided to run Jellyfin on my intel i5-10500 VM, I found there are some VAAPI driver errors with official or linuxserver Jellyfin docker image, so I created my own Jellyfin docker image. Hardware Acceleration works on my Intel UHD Graphics 630 now.

1. Image based on ubuntu focal
2. Support Intel Comet Lake iGPU
3. No ARM version available

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```sh
docker create \
  --name=jellyfin \
  -e TZ=Europe/London \
  -p 8096:8096 \
  -p 8920:8920 \ #optional
  -v /path/to/library:/config \
  -v /path/to/videos:/media \
  --device /dev/dri:/dev/dri \ #optional
  --restart unless-stopped \
  xjasonlyu/jellyfin
```

### docker-compose

Compatible with docker-compose v2 schemas.

```yaml
version: "2.4"
services:
  jellyfin:
    image: xjasonlyu/jellyfin
    container_name: jellyfin
    environment:
      - TZ=Europe/London
    volumes:
      - /path/to/library:/config
      - /path/to/videos:/media
    ports:
      - 8096:8096
      - 8920:8920 #optional
    devices:
      - /dev/dri:/dev/dri #optional
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8096` | Http webUI. |
| `-p 8920` | Https webUI (you need to set up your own certificate). |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-v /config` | Jellyfin data storage location. *This can grow very large, 50gb+ is likely for a large collection.* |
| `-v /media` | Media goes here. Add as many as needed e.g. `/media/movies`, `/media/tv`, etc. |
| `--device /dev/dri` | Only needed if you want to use your Intel GPU for hardware accelerated video encoding (vaapi). |

## Application Setup

Webui can be found at `http://<your-ip>:8096`

More information can be found in their official documentation [here](https://jellyfin.org/docs/general/quick-start.html) .

## Hardware Acceleration

### Intel

Hardware acceleration users for Intel Quicksync will need to mount their /dev/dri video device inside of the container by passing the following command when running or creating the container:

`--device=/dev/dri:/dev/dri`

We will automatically ensure the abc user inside of the container has the proper permissions to access this device.

### Nvidia

Hardware acceleration users for Nvidia will need to install the container runtime provided by Nvidia on their host, instructions can be found here:

https://github.com/NVIDIA/nvidia-docker

We automatically add the necessary environment variable that will utilise all the features available on a GPU on the host. Once nvidia-docker is installed on your host you will need to re/create the docker container with the nvidia container runtime `--runtime=nvidia` and add an environment variable `-e NVIDIA_VISIBLE_DEVICES=all` (can also be set to a specific gpu's UUID, this can be discovered by running `nvidia-smi --query-gpu=gpu_name,gpu_uuid --format=csv` ). NVIDIA automatically mounts the GPU and drivers from your host into the jellyfin docker container.

## Support Info

* Shell access whilst the container is running: `docker exec -it jellyfin /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f jellyfin`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' jellyfin`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' xjasonlyu/jellyfin`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```sh
git clone https://github.com/xjasonlyu/jellyfin-docker.git
cd jellyfin-docker
docker build \
  --no-cache \
  --pull \
  -t xjasonlyu/jellyfin:latest .
```
