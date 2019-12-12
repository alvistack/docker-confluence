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

FROM ubuntu:18.04

ENV LANG   "en_US.utf8"
ENV LC_ALL "en_US.utf8"
ENV SHELL  "/bin/bash"
ENV TZ     "UTC"

ENV CONFLUENCE_VERSION           "7.1.2"
ENV CONFLUENCE_OWNER             "confluence"
ENV CONFLUENCE_GROUP             "confluence"
ENV CONFLUENCE_HOME              "/var/atlassian/application-data/confluence"
ENV CONFLUENCE_CATALINA          "/opt/atlassian/confluence"
ENV JVM_MINIMUM_MEMORY           "1024m"
ENV JVM_MAXIMUM_MEMORY           "1024m"
ENV CATALINA_CONNECTOR_PROXYNAME ""
ENV CATALINA_CONNECTOR_PROXYPORT ""
ENV CATALINA_CONNECTOR_SCHEME    "http"
ENV CATALINA_CONNECTOR_SECURE    "false"
ENV CATALINA_CONTEXT_PATH        "/"
ENV JVM_SUPPORT_RECOMMENDED_ARGS "-Datlassian.plugins.enable.wait=300 -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1"
ENV SESSION_TIMEOUT              "300"
ENV PATH                          "$PATH:$CONFLUENCE_CATALINA/bin"

VOLUME  $CONFLUENCE_HOME
WORKDIR $CONFLUENCE_HOME

EXPOSE 8000
EXPOSE 8090

ENTRYPOINT [ "dumb-init", "--", "docker-entrypoint.sh" ]
CMD        [ "start-confluence.sh", "-fg" ]

# Hotfix for en_US.utf8 locale
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Explicitly set system user UID/GID
RUN set -ex \
    && groupadd -r $CONFLUENCE_OWNER \
    && useradd -r -g $CONFLUENCE_GROUP -d $CONFLUENCE_HOME -M -s /usr/sbin/nologin $CONFLUENCE_OWNER

# Prepare APT dependencies
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl gcc git libffi-dev libssl-dev lsb-release make python3 python3-dev sudo \
    && rm -rf /var/lib/apt/lists/*

# Install PIP
RUN set -ex \
    && curl -skL https://bootstrap.pypa.io/get-pip.py | python3

# Copy files
COPY files /

# Bootstrap with Ansible
RUN set -ex \
    && cd /etc/ansible/roles/localhost \
    && pip3 install --upgrade --ignore-installed --requirement requirements.txt \
    && molecule dependency \
    && molecule lint \
    && molecule syntax \
    && molecule converge \
    && molecule verify \
    && rm -rf /var/cache/ansible/* \
    && rm -rf /root/.cache/* \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*
