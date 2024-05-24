# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.13.0
ARG WEEWX_UID=421
ARG WEEWX_VERSION=4.10.2
ARG WEEWX_HOME="/home/weewx"

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM python:${PYTHON_VERSION} AS build-stage

ARG WEEWX_VERSION
ARG ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"

COPY --from=xx / /
RUN apt-get update && apt-get install -y clang lld
ARG TARGETPLATFORM
RUN xx-apt install -y libc6-dev

WORKDIR /tmp
RUN \
  --mount=type=cache,mode=0777,target=/var/cache/apt \
  --mount=type=cache,mode=0777,target=/root/.cache/pip <<EOF
apt-get update
python -m pip install --upgrade pip
pip install --upgrade virtualenv
virtualenv /opt/venv
EOF

COPY README.md requirements.txt setup.py ./
COPY src/_version.py ./src/_version.py

# Python setup
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache --requirement requirements.txt

WORKDIR /root

COPY src/entrypoint.sh src/_version.py ./

FROM python:${PYTHON_VERSION}-slim AS final-stage

ARG TARGETPLATFORM
ARG WEEWX_HOME
ARG WEEWX_UID

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="markf+github@geekpad.com"
LABEL org.opencontainers.image.vendor="Geekpad"

RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

RUN apt-get update && apt-get install -y libusb-1.0-0 gosu busybox-syslogd tzdata

WORKDIR ${WEEWX_HOME}

COPY --from=build-stage /opt/venv /opt/venv
COPY --from=build-stage /root ${WEEWX_HOME}

RUN mkdir /data \
  && chown -R weewx:weewx /data

VOLUME ["/data"]

ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["./entrypoint.sh"]
