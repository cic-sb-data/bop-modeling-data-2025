FROM mcr.microsoft.com/devcontainers/base:bullseye 
ARG DEBIAN_FRONTEND=noninteractive

COPY ../pyproject.toml /dbt/pyproject.toml
WORKDIR /dbt

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        git \
        python3 \
        curl \
        wget \
        python3-pip \
        python3-venv \
        python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && python3 -m pip install --break-system-packages uv

RUN uv sync

