# (c) Wong Hoi Sing Edison <hswong3i@pantarei-design.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

ENV CONFLUENCE_OWNER             "daemon"
ENV CONFLUENCE_GROUP             "daemon"
ENV CONFLUENCE_HOME              "/var/atlassian/application-data/confluence"
ENV CONFLUENCE_CATALINA          "/opt/atlassian/confluence"
ENV CONFLUENCE_DOWNLOAD_URL      "http://downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-6.7.1.tar.gz"

ENV JAVA_HOME                    "/usr/java/default"
ENV JAVA_DOWNLOAD_URL            "http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jre-8u162-linux-x64.rpm"

ENV DUMB_INIT_BIN_DIR            "/usr/local/bin"
ENV DUMB_INIT_DOWNLOAD_URL       "https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64"

ENV JVM_MINIMUM_MEMORY           "1024m"
ENV JVM_MAXIMUM_MEMORY           "1024m"
ENV CATALINA_CONNECTOR_PROXYNAME ""
ENV CATALINA_CONNECTOR_PROXYPORT ""
ENV CATALINA_CONNECTOR_SCHEME    "http"
ENV CATALINA_CONNECTOR_SECURE    "false"
ENV CATALINA_CONTEXT_PATH        ""
ENV JVM_SUPPORT_RECOMMENDED_ARGS "-Datlassian.plugins.enable.wait=300"

VOLUME $CONFLUENCE_HOME
WORKDIR $CONFLUENCE_HOME

EXPOSE 8080 8005

ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]
CMD [ "/etc/init.d/confluence", "start", "-fg" ]

# Prepare APT depedencies
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractiev apt-get install -y alien apt-transport-https apt-utils aptitude bzip2 ca-certificates curl debian-archive-keyring debian-keyring git htop psmisc python-apt rsync sudo unzip vim wget zip \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle JRE
RUN set -ex \
    && ln -s /usr/bin/update-alternatives /usr/sbin/alternatives \
    && ARCHIVE="`mktemp --suffix=.rpm`" \
    && curl -skL -j -H "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD_URL > $ARCHIVE \
    && alien -i -k --scripts $ARCHIVE \
    && rm -rf $ARCHIVE

# Install Atlassian CONFLUENCE
RUN set -ex \
    && ARCHIVE="`mktemp --suffix=tar.gz`" \
    && curl -skL $CONFLUENCE_DOWNLOAD_URL > $ARCHIVE \
    && mkdir -p $CONFLUENCE_CATALINA \
    && tar zxf $ARCHIVE --strip-components=1 -C $CONFLUENCE_CATALINA \
    && chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_CATALINA \
    && rm -rf $ARCHIVE

# Install dumb-init
RUN set -ex \
    && curl -skL $DUMB_INIT_DOWNLOAD_URL > $DUMB_INIT_BIN_DIR/dumb-init \
    && chmod 0755 $DUMB_INIT_BIN_DIR/dumb-init

# Copy files
COPY files /

# Ensure required folders exist with correct owner:group
RUN set -ex \
    && mkdir -p $CONFLUENCE_HOME $CONFLUENCE_CATALINA \
    && chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_HOME $CONFLUENCE_CATALINA
