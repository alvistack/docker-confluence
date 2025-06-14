# Docker Image Packaging for Atlassian Confluence

<a href="https://alvistack.com" title="AlviStack" target="_blank"><img src="/alvistack.svg" height="75" alt="AlviStack"></a>

[![GitLab pipeline
status](https://img.shields.io/gitlab/pipeline/alvistack/docker-confluence/master)](https://gitlab.com/alvistack/docker-confluence/-/pipelines)
[![GitHub
tag](https://img.shields.io/github/tag/alvistack/docker-confluence.svg)](https://github.com/alvistack/docker-confluence/tags)
[![GitHub
license](https://img.shields.io/github/license/alvistack/docker-confluence.svg)](https://github.com/alvistack/docker-confluence/blob/master/LICENSE)
[![Docker
Pulls](https://img.shields.io/docker/pulls/alvistack/confluence-9.5.svg)](https://hub.docker.com/r/alvistack/confluence-9.5)

Confluence is where you create, organize and discuss work with your
team.

Learn more about Confluence:
<https://www.atlassian.com/software/confluence>

## Supported Tags and Respective Packer Template Links

- [`alvistack/confluence-9.5`](https://hub.docker.com/r/alvistack/confluence-9.5)
  - [`packer/docker-9.5/packer.json`](https://github.com/alvistack/docker-confluence/blob/master/packer/docker-9.5/packer.json)
- [`alvistack/confluence-9.2`](https://hub.docker.com/r/alvistack/confluence-9.2)
  - [`packer/docker-9.2/packer.json`](https://github.com/alvistack/docker-confluence/blob/master/packer/docker-9.2/packer.json)
- [`alvistack/confluence-8.5`](https://hub.docker.com/r/alvistack/confluence-8.5)
  - [`packer/docker-8.5/packer.json`](https://github.com/alvistack/docker-confluence/blob/master/packer/docker-8.5/packer.json)

## Overview

This Docker container makes it easy to get an instance of Confluence up
and running.

Based on [Official Ubuntu Docker
Image](https://hub.docker.com/_/ubuntu/) with some minor hack:

- Packaging by Packer Docker builder and Ansible provisioner in single
  layer
- Handle `ENTRYPOINT` with
  [catatonit](https://github.com/openSUSE/catatonit)

### Quick Start

For the `Confluence_HOME` directory that is used to store the repository
data (amongst other things) we recommend mounting a host directory as a
[data
volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes),
or via a named volume if using a docker version \>= 1.9.

Volume permission is NOT managed by entry scripts. To get started you
can use a data volume, or named volumes.

Start Atlassian Confluence Server:

    # Pull latest image
    docker pull alvistack/confluence-9.5

    # Run as detach
    docker run \
        -itd \
        --name confluence \
        --publish 8090:8090 \
        --volume /var/atlassian/application-data/confluence:/var/atlassian/application-data/confluence \
        alvistack/confluence-9.5

**Success**. Confluence is now available on <http://localhost:8090>

Please ensure your container has the necessary resources allocated to
it. We recommend 2GiB of memory allocated to accommodate both the
application server and the git processes. See [Supported
Platforms](https://confluence.atlassian.com/display/Confluence/Supported+Platforms)
for further information.

## Upgrade

To upgrade to a more recent version of Confluence Server you can simply
stop the Confluence container and start a new one based on a more recent
image:

    docker stop confluence
    docker rm confluence
    docker run ... (see above)

As your data is stored in the data volume directory on the host, it will
still be available after the upgrade.

Note: Please make sure that you don't accidentally remove the confluence
container and its volumes using the -v option.

## Backup

For evaluations you can use the built-in database that will store its
files in the Confluence Server home directory. In that case it is
sufficient to create a backup archive of the directory on the host that
is used as a volume (`/var/atlassian/application-data/confluence` in the
example above).

## Versioning

### `YYYYMMDD.Y.Z`

Release tags could be find from [GitHub
Release](https://github.com/alvistack/docker-confluence/tags) of this
repository. Thus using these tags will ensure you are running the most
up to date stable version of this image.

### `YYYYMMDD.0.0`

Version tags ended with `.0.0` are rolling release rebuild by [GitLab
pipeline](https://gitlab.com/alvistack/docker-confluence/-/pipelines) in
weekly basis. Thus using these tags will ensure you are running the
latest packages provided by the base image project.

## License

- Code released under [Apache License 2.0](LICENSE)
- Docs released under [CC BY
  4.0](http://creativecommons.org/licenses/by/4.0/)

## Author Information

- Wong Hoi Sing Edison
  - <https://twitter.com/hswong3i>
  - <https://github.com/hswong3i>
