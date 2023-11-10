# base
FROM ubuntu:22.04

# Update Package
RUN apt-get update
# Install apt-utils
RUN apt-get install -y --no-install-recommends apt-utils
# Install Sudo
RUN apt-get -y install sudo
# Install Curl
RUN apt-get -y install curl
# Install VIM
RUN apt-get -y install vim

# set the github runner version
ARG RUNNER_VERSION="2.311.0"

# update the base packages, add a non-sudo user, and install Xvfb
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y xvfb libglib2.0-0 && \
    useradd -m docker && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]