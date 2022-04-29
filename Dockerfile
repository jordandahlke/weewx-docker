FROM python:3.10.4-alpine3.15 as install-weewx-stage

ARG WEEWX_UID=1003
ENV WEEWX_HOME="/home/weewx"
ENV WEEWX_VERSION="4.8.0"
ENV ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /tmp
COPY src/hashes requirements.txt ./

# Download sources and verify hashes
RUN addgroup --system --gid ${WEEWX_UID} weewx \
    && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx \
    && apk --no-cache add tar \
    && wget -O "${ARCHIVE}" "https://weewx.com/downloads/released_versions/${ARCHIVE}" \
    && wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip \
    && wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip \
    && wget -O weewx-influx2.zip https://github.com/jordandahlke/weewx-influx2/archive/refs/tags/v0.10.1.zip \
    && wget -O weewx-weatherlink.zip https://github.com/michael-slx/weewx-weatherlink-live/archive/refs/heads/release.zip \
    && wget -O weewx-wlldriver.zip https://github.com/jordandahlke/weatherlinklive-driver-weewx/archive/refs/tags/2022.04-1.zip \
    && sha256sum -c < hashes \
# WeeWX setup
    && tar --extract --gunzip --directory ${WEEWX_HOME} --strip-components=1 --file "${ARCHIVE}" \
    && chown -R weewx:weewx ${WEEWX_HOME} \
# Python setup
    &&  python -m venv /opt/venv \
    && pip install --no-cache --requirement requirements.txt \
    && ${WEEWX_HOME}/bin/wee_extension --install /tmp/weewx-mqtt.zip \
    && ${WEEWX_HOME}/bin/wee_extension --install /tmp/weewx-interceptor.zip \
    && ${WEEWX_HOME}/bin/wee_extension --install /tmp/weewx-influx2.zip \
    && ${WEEWX_HOME}/bin/wee_extension --install /tmp/weewx-weatherlink.zip \
    && ${WEEWX_HOME}/bin/wee_extension --install /tmp/weewx-wlldriver.zip

WORKDIR ${WEEWX_HOME}
COPY src/entrypoint.sh src/version.txt ./

FROM python:3.10.4-slim-bullseye as final-stage

ARG TARGETPLATFORM
ARG WEEWX_UID=1003
ENV WEEWX_HOME="/home/weewx"
ENV WEEWX_VERSION="4.8.0"

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="jdahlke@gmail.com"
LABEL org.opencontainers.image.vendor="Me"
LABEL com.weewx.version=${WEEWX_VERSION}

RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx \
  && apt-get update && apt-get install -y libusb-1.0-0 gosu busybox-syslogd tzdata default-mysql-client

WORKDIR ${WEEWX_HOME}

COPY --from=install-weewx-stage /opt/venv /opt/venv
COPY --from=install-weewx-stage ${WEEWX_HOME} ${WEEWX_HOME}
COPY --from=install-weewx-stage /tmp /tmp

RUN mkdir /data && \
  cp weewx.conf /data
VOLUME ["/data"]

ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["./entrypoint.sh"]
CMD ["/data/weewx.conf"]
