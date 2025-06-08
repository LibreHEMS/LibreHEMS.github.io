FROM registry.access.redhat.com/ubi9/ubi:latest AS base

ENV container=oci
ENV USER=default

USER root

# Check for package update
RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
    # Install git, nano, ruby, rubygems-devel, gcc, make
    dnf install nano git ruby rubygems-devel gcc make -y; \
    # clear cache
    dnf clean all

# Dev target
FROM base AS dev
COPY .devcontainer/devtools.sh /tmp/devtools.sh
RUN  /tmp/devtools.sh
USER default


