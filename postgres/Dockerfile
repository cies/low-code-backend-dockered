# Builds the ZomboDB extension for Postgres 13 running on Debian Buster
# This requires lots of tools.

FROM debian:buster

ARG USER=docker
ARG UID=1000
ARG GID=1000
RUN useradd -m ${USER} --uid=${UID}

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y -qq --fix-missing
RUN apt-get install -y wget gnupg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt-get update -y --fix-missing

RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y gcc make build-essential libz-dev zlib1g-dev strace libssl-dev pkg-config
RUN apt-get install -y postgresql-13 postgresql-server-dev-13
RUN apt-get install -y ruby ruby-dev rubygems build-essential
RUN gem install --no-document fpm

RUN chown ${UID}:${GID} /usr/share/postgresql/13/extension
RUN chown ${UID}:${GID} /usr/lib/postgresql/13/lib
USER ${UID}:${GID}
WORKDIR /home/${USER}
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

RUN cargo install cargo-pgx --version 0.1.21
RUN cargo pgx init --pg13=/usr/lib/postgresql/13/bin/pg_config


RUN git clone --depth=1 https://github.com/zombodb/zombodb.git
WORKDIR zombodb
RUN cargo pgx install --release


# Then copy over the extension to the official "Postgres 13 on Debian Buster" container
# We dont need thoses GBs of tooling to actually use the extension.

FROM postgres:13.4-buster
COPY --from=0 /usr/lib/postgresql/13/lib/zombodb.so /usr/lib/postgresql/13/lib/
COPY --from=0 /usr/share/postgresql/13/extension/zombodb.control /usr/share/postgresql/13/extension/
COPY --from=0 /usr/share/postgresql/13/extension/zombodb--3000.0.3.sql /usr/share/postgresql/13/extension/

