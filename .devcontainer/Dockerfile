# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.163.1/containers/cpp/.devcontainer/base.Dockerfile

# [Choice] Debian / Ubuntu version: debian-10, debian-9, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="ubuntu-20.04"
FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-${VARIANT}

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get upgrade -y -q && \
    apt-get install -y -q \
    build-essential \
    make \
    cmake \
    clang-tidy \
    clang-format \
    git \
    python3 \
    bzip2 \
    gcc-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    libnewlib-arm-none-eabi \
    ca-certificates \
    wget \
    gdb-multiarch \
    openocd \
    ncurses-dev \
    curl && \
    apt-get clean

# This is required to get arm-none-eabi-gdb working
RUN  cd /usr/lib/x86_64-linux-gnu && \
    ln -s libncurses.so.6.2 libncurses.so.5 && \
    ln -s libtinfo.so.6.2 libtinfo.so.5 && \
    ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb

# make some useful symlinks that are expected to exist
RUN cd /usr/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s python3-config python-config
