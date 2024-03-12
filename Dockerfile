FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN /bin/echo -e "deb http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse" > /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install python3-pip python3-venv libpython3-dev python-setuptools build-essential libffi-dev libssl-dev iputils-ping
RUN apt-get clean

RUN rm -rf /var/lib/apt/lists/*

RUN adduser --system --no-create-home --shell /bin/false --group pyop

COPY . /opt/pyop/src/
COPY docker/setup.sh /opt/pyop/setup.sh
COPY docker/start.sh /start.sh
RUN /opt/pyop/setup.sh

# Add Dockerfile to the container as documentation
COPY Dockerfile /Dockerfile

WORKDIR /

EXPOSE 9090

CMD ["bash", "/start.sh"]