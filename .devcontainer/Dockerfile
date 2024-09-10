FROM letssteam/makecode-toolchain:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cu \
    curl \
    make \
    software-properties-common \
    tar \
    udev \
    usbutils && \
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN adduser vscode dialout && \
    adduser vscode plugdev