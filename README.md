Docker Image Packaging for Atlassian Confluence
===============================================

[![Travis](https://img.shields.io/travis/alvistack/docker-confluence.svg)](https://travis-ci.org/alvistack/docker-confluence)
[![GitHub release](https://img.shields.io/github/release/alvistack/docker-confluence.svg)](https://github.com/alvistack/docker-confluence/releases)
[![GitHub license](https://img.shields.io/github/license/alvistack/docker-confluence.svg)](https://github.com/alvistack/docker-confluence/blob/master/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/alvistack/confluence.svg)](https://hub.docker.com/r/alvistack/confluence/)

Confluence is where you create, organize and discuss work with your team.

Learn more about Confluence: <https://www.atlassian.com/software/confluence>

Supported Tags and Respective `Dockerfile` Links
------------------------------------------------

-   [`latest` (master/Dockerfile)](https://github.com/alvistack/docker-confluence/blob/master/Dockerfile)
-   [`6.11` (6.11/Dockerfile)](https://github.com/alvistack/docker-confluence/blob/6.11/Dockerfile)

Overview
--------

This Docker container makes it easy to get an instance of Confluence up and running.

### Quick Start

For the `Confluence_HOME` directory that is used to store the repository data (amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes), or via a named volume if using a docker version &gt;= 1.9.

Volume permission is managed by entry scripts. To get started you can use a data volume, or named volumes.

Start Atlassian Confluence Server:

    # Pull latest image
    docker pull alvistack/confluence

    # Run as detach
    docker run \
        -itd \
        --name confluence \
        --publish 8090:8090 \
        --volume /var/atlassian/application-data/confluence:/var/atlassian/application-data/confluence \
        alvistack/confluence

**Success**. Confluence is now available on <http://localhost:8090>

Please ensure your container has the necessary resources allocated to it. We recommend 2GiB of memory allocated to accommodate both the application server and the git processes. See [Supported Platforms](https://confluence.atlassian.com/display/Confluence/Supported+Platforms) for further information.

### Memory / Heap Size

If you need to override Confluence's default memory allocation, you can control the minimum heap (Xms) and maximum heap (Xmx) via the below environment variables.

#### JVM\_MINIMUM\_MEMORY

The minimum heap size of the JVM

Default: `1024m`

#### JVM\_MAXIMUM\_MEMORY

The maximum heap size of the JVM

Default: `1024m`

### Reverse Proxy Settings

If Confluence is run behind a reverse proxy server, then you need to specify extra options to make Confluence aware of the setup. They can be controlled via the below environment variables.

#### CATALINA\_CONNECTOR\_PROXYNAME

The reverse proxy's fully qualified hostname.

Default: *NONE*

#### CATALINA\_CONNECTOR\_PROXYPORT

The reverse proxy's port number via which Confluence is accessed.

Default: *NONE*

#### CATALINA\_CONNECTOR\_SCHEME

The protocol via which Confluence is accessed.

Default: `http`

#### CATALINA\_CONNECTOR\_SECURE

Set 'true' if CATALINA\_CONNECTOR\_SCHEME is 'https'.

Default: `false`

#### CATALINA\_CONTEXT\_PATH

The context path via which Confluence is accessed.

Default: *NONE*

### JVM configuration

If you need to pass additional JVM arguments to Confluence such as specifying a custom trust store, you can add them via the below environment variable

#### JVM\_SUPPORT\_RECOMMENDED\_ARGS

Additional JVM arguments for Confluence

Default: `-Datlassian.plugins.enable.wait=300`

### Synchrony configuration

When running with individual Synchrony Cluster for Confluence Data Center, you should customize via the below environment variables.

Start Synchrony Cluster:

    # Run as detach
    docker run \
        -itd \
        --name synchrony \
        --publish 8091:8091 \
        --env SYNCHRONY_BIND=127.0.0.1 \
        --env SYNCHRONY_DATABASE_URL="jdbc:postgresql://localhost:5432/postgres" \
        --env SYNCHRONY_DATABASE_USERNAME="postgres" \
        --env SYNCHRONY_DATABASE_PASSWORD="postgres" \
        --env SYNCHRONY_SERVICE_URL="http://localhost:8090/synchrony-proxy" \
        alvistack/confluence \
        /opt/atlassian/confluence/bin/synchrony/start-synchrony.sh -fg

#### SYNCHRONY\_BIND

Public IP address or hostname of this Synchrony node.

Default: *NONE*

#### SYNCHRONY\_DATABASE\_URL

This is the URL for your Confluence database.

Default: *NONE*

#### SYNCHRONY\_DATABASE\_USERNAME

This is the username of your Confluence database user.

Default: *NONE*

#### SYNCHRONY\_DATABASE\_PASSWORD

This is the password for your Confluence database user.

Default: *NONE*

#### CLUSTER\_JOIN\_PROPERTIES

This determines how Synchrony should discover nodes.

Default: `-Dcluster.join.type=multicast`

#### DATABASE\_DRIVER\_PATH

This is the path to your database driver file.

Default: `/opt/atlassian/confluence/confluence/WEB-INF/lib/postgresql-42.1.1.jar`

#### SYNCHRONY\_JAR\_PATH

This is the path to the synchrony-standalone.jar file you copied to this node.

Default: `/opt/atlassian/confluence/confluence/WEB-INF/packages/synchrony-standalone.jar`

#### SYNCHRONY\_SERVICE\_URL

This is the URL that the browser uses to contact Synchrony.

Default: *NONE*

#### OPTIONAL\_OVERRIDES

You can choose to specify additional system properties.

Default: *NONE*

Upgrade
-------

To upgrade to a more recent version of Confluence Server you can simply stop the Confluence
container and start a new one based on a more recent image:

    docker stop confluence
    docker rm confluence
    docker run ... (see above)

As your data is stored in the data volume directory on the host, it will still
be available after the upgrade.

Note: Please make sure that you don't accidentally remove the confluence container and its volumes using the -v option.

Backup
------

For evaluations you can use the built-in database that will store its files in the Confluence Server home directory. In that case it is sufficient to create a backup archive of the directory on the host that is used as a volume (`/var/atlassian/application-data/confluence` in the example above).

Versioning
----------

The `latest` tag matches the most recent version of this repository. Thus using `alvistack/confluence:latest` or `alvistack/confluence` will ensure you are running the most up to date version of this image.

License
-------

-   Code released under [Apache License 2.0](LICENSE)
-   Docs released under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/)

Author Information
------------------

-   Wong Hoi Sing Edison
    -   <https://twitter.com/hswong3i>
    -   <https://github.com/hswong3i>

