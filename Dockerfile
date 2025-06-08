FROM registry.access.redhat.com/ubi10/ubi:latest AS base

ENV container=oci
ENV USER=default

USER root

# Check for package update
RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
    # Install git, nano, openssl-devel, ruby, rubygems-devel, rubygem-bundler, gcc,  gcc-c++, make
    dnf install nano git openssl-devel ruby ruby-devel rubygems-devel rubygem-bundler gcc make  gcc-c++ -y; \
    # Install jekyll
    gem install jekyll; \
    # clear cache
    dnf clean all
    
# Dev target
FROM base AS dev
COPY .devcontainer/devtools.sh /tmp/devtools.sh
RUN  /tmp/devtools.sh
USER default


