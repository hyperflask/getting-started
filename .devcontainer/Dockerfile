FROM nikolaik/python-nodejs:python3.13-nodejs24

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install git, process tools, lsb-release (common in install instructions for CLIs)
RUN apt-get -y install git procps lsb-release

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu[0-9][0-9]

RUN mkdir /workspace
WORKDIR /workspace
RUN pip install -U setuptools wheel pip

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=
