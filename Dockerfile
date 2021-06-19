FROM piwi3910/base:latest

LABEL maintainer="Pascal Watteel"


#
# Add nzbhydra2 init script.
#
COPY nzbhydra2.sh /nzbhydra2.sh

#
# Fix locales to handle UTF-8 characters.
#
ENV LANG C.UTF-8

#
# Specify versions of software to install.
#
ARG NZBHYDRA2_VERSION=DEFAULT

#
# Add (download) nzbhydra2
#
ADD https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VERSION}/nzbhydra2-${NZBHYDRA2_VERSION}.linux.zip /tmp/nzbhydra2.zip

#
# Install nzbhydra2 and requied dependencies
#
RUN adduser -u 666 -D -h /nzbhydra2 -s /bin/bash nzbhydra2 nzbhydra2 && \
    chmod 755 /nzbhydra2.sh && \
    unzip /tmp/nzbhydra2.zip -d /nzbhydra2 && \
    apk update && \
	apk add --no-cache python3 ca-certificates shadow openjdk11-jre-headless && \
    update-ca-certificates && \
    chown -R nzbhydra2: nzbhydra2 && \
    rm -rf /tmp/nzb* && \

#
# Define container settings.
#
VOLUME ["/datadir"]

EXPOSE 5076

#
# Start nzbhydra2.
#

WORKDIR /nzbhydra2

CMD ["/nzbhydra2.sh"]
