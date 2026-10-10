FROM mcr.microsoft.com/devcontainers/java:1-21-bookworm

ARG NEXTFLOW_VERSION=26.04.7

ENV NXF_HOME=/home/vscode/.nextflow

USER root

RUN rm -f /etc/apt/sources.list.d/yarn.list

USER vscode

RUN set -eux; \
    cd /tmp; \
    export NXF_VER="${NEXTFLOW_VERSION}"; \
    curl -fsSL https://get.nextflow.io | bash; \
    sudo install -m 0755 nextflow /usr/local/bin/nextflow; \
    rm nextflow; \
    nextflow -version
