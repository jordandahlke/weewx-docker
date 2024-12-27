# weewx-docker 🌩🐳 #

[![GitHub Build Status](https://github.com/felddy/weewx-docker/workflows/Build/badge.svg)](https://github.com/felddy/weewx-docker/actions)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/felddy/weewx-docker/badge)](https://securityscorecards.dev/viewer/?uri=github.com/felddy/weewx-docker)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6003/badge)](https://bestpractices.coreinfrastructure.org/projects/6003)
[![CodeQL](https://github.com/felddy/weewx-docker/workflows/CodeQL/badge.svg)](https://github.com/felddy/weewx-docker/actions/workflows/codeql-analysis.yml)
[![WeeWX Version](https://img.shields.io/github/v/release/felddy/weewx-docker?color=brightgreen)](https://hub.docker.com/r/felddy/weewx)

[![Docker Pulls](https://img.shields.io/docker/pulls/felddy/weewx)](https://hub.docker.com/r/felddy/weewx)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/felddy/weewx)](https://hub.docker.com/r/felddy/weewx)
[![Platforms](https://img.shields.io/badge/platforms-amd64%20%7C%20arm%2Fv6%20%7C%20arm%2Fv7%20%7C%20arm64%20%7C%20ppc64le%20%7C%20s390x-blue)](https://hub.docker.com/r/felddy/weewx/tags)

This docker container can be used to quickly get a
[WeeWX](http://weewx.com) instance up and running.

## Running ##

The easiest way to start the container is to create a
`docker-compose.yml` similar to the following.  If you use a
serial port to connect to your weather station, make sure the
container has permissions to access the port.

Modify any paths or devices as needed:

```yaml
---
name: "weewx"

services:
  weewx:
    image: felddy/weewx:5.1.0
    volumes:
      - type: bind
        source: ./data
        target: /data
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0"
```

1. Create a directory on the host to store the configuration and database files:

    ```console
    mkdir data
    ```

1. If this is the first time running weewx, use the following command to start
   the container and generate a configuration file:

    ```console
    docker compose run --rm weewx
    ```

1. The configuration file will be created in the `data` directory.  You should
   edit this file to match the setup of your weather station.

1. When you are satisfied with configuration the container can be started in the
   background with:

    ```console
    docker compose up --detach
    ```

## Upgrading ##

1. Stop the running container:

    ```console
    docker compose down
    ```

1. Pull the new images from the Docker hub:

    ```console
    docker compose pull
    ```

1. Update your configuration file (a backup will be created):

    ```console
    docker compose run --rm weewx station upgrade
    ```

1. Read through the new configuration and verify.
   It is helpful to `diff` the new config with the backup.  Check the
   [WeeWX Upgrade Guide](http://weewx.com/docs/upgrading.htm#Instructions_for_specific_versions)
   for instructions for specific versions.

1. Start the container up with the new image version:

    ```console
    docker compose up --detach
    ```

## Migrating ##

If you are migrating from a non-containerized WeeWX installation, you will need to
configure the logger to write to the console.  Adding the following your `weewx.conf`
will allow you to see the log output:

```ini
[Logging]
    [[root]]
        level = INFO
        handlers = console,
```

## Installing WeeWX Extensions ##

```console
docker compose run --rm weewx \
  extension install --yes \
  https://github.com/matthewwall/weewx-windy/archive/master.zip
```

```console
docker compose run --rm weewx \
  extension install --yes \
  https://github.com/matthewwall/weewx-mqtt/archive/master.zip
```

## Installing Additional Python Packages ##

```console
docker compose run --rm --entrypoint pip weewx install paho_mqtt
```

## Volumes ##

| Mount point | Purpose        |
|-------------|----------------|
| `/data`     | configuration file and sqlite database storage |

## Building from source ##

Build the image locally using this git repository as the [build context](https://docs.docker.com/engine/reference/commandline/build/#git-repositories):

```console
docker build \
  --tag felddy/weewx:5.1.0 \
  https://github.com/felddy/weewx-docker.git#develop
```

## Cross-platform builds ##

To create images that are compatible with other platforms you can use the
[`buildx`](https://docs.docker.com/buildx/working-with-buildx/) feature of
Docker:

1. Copy the project to your machine using the `Clone` button above
   or the command line:

    ```console
    git clone https://github.com/felddy/weewx-docker.git
    cd weewx-docker
    ```

1. Build the image using `buildx`:

    ```console
    docker buildx build \
      --platform linux/amd64 \
      --output type=docker \
      --tag felddy/weewx:5.1.0 .
    ```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
