# Builds the ZomboDB extension for Postgres 13 running on Debian Buster
# This requires lots of tools.

FROM debian:bullseye

# Version pinning
# * ZDB_BRANCH can also be a tag
# * make sure to update the versions in the target container steps by hand!
ARG ZDB_VERSION=3000.0.11
ARG ZDB_BRANCH=v${ZDB_VERSION}
ARG PG_VERSION=14
ARG CARGO_PGX_VERSION=0.4.2

ARG USER=docker
ARG UID=1000
ARG GID=1000

RUN useradd -m ${USER} --uid=${UID}

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y -qq --fix-missing
RUN apt-get install -y wget gnupg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt-get update -y --fix-missing
RUN apt-get install -y curl

RUN apt-get install -y gcc make build-essential libz-dev zlib1g-dev strace libssl-dev pkg-config git
RUN apt-get install -y postgresql-${PG_VERSION} postgresql-server-dev-${PG_VERSION}
RUN apt-get install -y ruby ruby-dev rubygems build-essential
RUN gem install --no-document fpm

RUN mkdir -p /usr/lib/postgresql/${PG_VERSION}/lib
RUN chown 1000:1000 /usr/lib/postgresql/${PG_VERSION}/lib
RUN mkdir -p /usr/share/postgresql/${PG_VERSION}/extension
RUN chown 1000:1000 /usr/share/postgresql/${PG_VERSION}/extension

USER ${UID}:${GID}
WORKDIR /home/${USER}
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

RUN cargo install cargo-pgx --version ${CARGO_PGX_VERSION}
RUN cargo pgx init --pg${PG_VERSION}=/usr/lib/postgresql/${PG_VERSION}/bin/pg_config

RUN git clone --branch=${ZDB_BRANCH} --depth=1 https://github.com/zombodb/zombodb.git
WORKDIR zombodb
RUN cargo pgx install --release


# Then copy over the extension to the official "Postgres 13 on Debian Buster" container
# We dont need thoses GBs of tooling to actually use the extension.

FROM postgres:14.2-bullseye
COPY --from=0 /usr/lib/postgresql/14/lib/zombodb.so /usr/lib/postgresql/14/lib/
COPY --from=0 /usr/share/postgresql/14/extension/zombodb.control /usr/share/postgresql/14/extension/
COPY --from=0 /usr/share/postgresql/14/extension/zombodb--3000.0.11.sql /usr/share/postgresql/14/extension/

