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
ENV CONFLUENCE_DOWNLOAD_URL      "http://downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-6.12.2.tar.gz"
ENV JAVA_HOME                    "/usr/java/default"
ENV JVM_MINIMUM_MEMORY           "1024m"
ENV JVM_MAXIMUM_MEMORY           "1024m"
ENV CATALINA_CONNECTOR_PROXYNAME ""
ENV CATALINA_CONNECTOR_PROXYPORT ""
ENV CATALINA_CONNECTOR_SCHEME    "http"
ENV CATALINA_CONNECTOR_SECURE    "false"
ENV CATALINA_CONTEXT_PATH        ""
ENV JVM_SUPPORT_RECOMMENDED_ARGS "-Datlassian.plugins.enable.wait=300"
ENV TZ                           "UTC"
ENV SESSION_TIMEOUT              "60"

VOLUME  $CONFLUENCE_HOME
WORKDIR $CONFLUENCE_HOME

EXPOSE 8000
EXPOSE 8090

ENTRYPOINT [ "dumb-init", "--" ]
CMD        [ "/etc/init.d/confluence", "start", "-fg" ]

# Prepare APT depedencies
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y alien apt-transport-https apt-utils aptitude bzip2 ca-certificates curl debian-archive-keyring debian-keyring git htop patch psmisc python-apt rsync software-properties-common sudo tzdata unzip vim wget zip \
    && rm -rf /var/lib/apt/lists/*

# Install custom fonts
Run set -ex \
    && apt-get update \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y fonts-arphic-ukai fonts-arphic-uming fonts-beng fonts-beng-extra fonts-cantarell fonts-crosextra-caladea fonts-crosextra-carlito fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-deva fonts-deva-extra fonts-droid-fallback fonts-freefont-ttf fonts-gargi fonts-gubbi fonts-gujr fonts-gujr-extra fonts-guru fonts-guru-extra fonts-indic fonts-kacst fonts-kacst-one fonts-kalapi fonts-khmeros-core fonts-knda fonts-lao fonts-liberation fonts-linuxlibertine fonts-lklug-sinhala fonts-lohit-beng-assamese fonts-lohit-beng-bengali fonts-lohit-deva fonts-lohit-gujr fonts-lohit-guru fonts-lohit-knda fonts-lohit-mlym fonts-lohit-orya fonts-lohit-taml fonts-lohit-taml-classical fonts-lohit-telu fonts-mlym fonts-nakula fonts-nanum-coding fonts-navilu fonts-noto fonts-noto-cjk fonts-noto-hinted fonts-noto-mono fonts-noto-unhinted fonts-opensymbol fonts-orya fonts-orya-extra fonts-pagul fonts-sahadeva fonts-samyak-deva fonts-samyak-gujr fonts-samyak-mlym fonts-samyak-taml fonts-sarai fonts-sil-abyssinica fonts-sil-gentium fonts-sil-gentium-basic fonts-sil-padauk fonts-sipa-arundina fonts-smc fonts-takao-gothic fonts-takao-mincho fonts-takao-pgothic fonts-taml fonts-telu fonts-telu-extra fonts-thai-tlwg fonts-tibetan-machine fonts-tlwg-garuda fonts-tlwg-garuda-ttf fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf fonts-tlwg-loma fonts-tlwg-loma-ttf fonts-tlwg-mono fonts-tlwg-mono-ttf fonts-tlwg-norasi fonts-tlwg-norasi-ttf fonts-tlwg-purisa fonts-tlwg-purisa-ttf fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf fonts-ubuntu-font-family-console fonts-ubuntu-title fonts-unfonts-core ttf-mscorefonts-installer \
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle JRE
RUN set -ex \
    && ln -s /usr/bin/update-alternatives /usr/sbin/alternatives \
    && ARCHIVE="`mktemp --suffix=.rpm`" \
    && curl -skL -j -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jre-8u191-linux-x64.rpm > $ARCHIVE \
    && DEBIAN_FRONTEND=noninteractive alien -i -k --scripts $ARCHIVE \
    && rm -rf $ARCHIVE

# Install Atlassian CONFLUENCE
RUN set -ex \
    && ARCHIVE="`mktemp --suffix=.tar.gz`" \
    && curl -skL $CONFLUENCE_DOWNLOAD_URL > $ARCHIVE \
    && mkdir -p $CONFLUENCE_CATALINA \
    && tar zxf $ARCHIVE --strip-components=1 -C $CONFLUENCE_CATALINA \
    && chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_CATALINA \
    && rm -rf $ARCHIVE

# Install MySQL Connector/J JAR
RUN set -ex \
    && ARCHIVE="`mktemp --suffix=.tar.gz`" \
    && curl -skL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.12.tar.gz > $ARCHIVE \
    && tar zxf $ARCHIVE --strip-components=1 -C $CONFLUENCE_CATALINA/confluence/WEB-INF/lib/ mysql-connector-java-8.0.12/mysql-connector-java-8.0.12.jar \
    && rm -rf $ARCHIVE

# Install PostgreSQL JDBC JAR
RUN set -ex \
    && rm -rf $CONFLUENCE_CATALINA/confluence/WEB-INF/lib/*postgresql*.jar \
    && curl -skL https://jdbc.postgresql.org/download/postgresql-42.2.4.jar > $CONFLUENCE_CATALINA/confluence/WEB-INF/lib/postgresql-42.2.4.jar

# Install dumb-init
RUN set -ex \
    && curl -skL https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 > /usr/local/bin/dumb-init \
    && chmod 0755 /usr/local/bin/dumb-init

# Copy files
COPY files /

# Apply patches
RUN set -ex \
    && patch -d/ -p1 < /.patch

# Ensure required folders exist with correct owner:group
RUN set -ex \
    && mkdir -p $CONFLUENCE_HOME \
    && chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_HOME \
    && chmod 0755 $CONFLUENCE_HOME \
    && mkdir -p $CONFLUENCE_CATALINA \
    && chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_CATALINA \
    && chmod 0755 $CONFLUENCE_CATALINA
