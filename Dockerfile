FROM ubuntu:latest
RUN apt update \
        && apt upgrade -y \
        && apt install --no-install-recommends -y inetutils-ping unzip rpcbind wget ca-certificates \
        && update-ca-certificates \
        && rm -rf /var/lib/apt/lists/*

# Notes:
#
#   Edit the system.conf before building the docker image.
#
#   gemstone key file should be called gemstone.key and mounted at
#   /gemstone-key in the running container.  A simple way to
#   accomplish this is to create a docker volume, place your key file
#   in it and mount it when you run the gemstone image.  By default
#   the community license is placed in that location.  See the KEYFILE
#   variable in system.conf.
#
#   gemstone data volume should be mounted at /gemstone-data.  Again,
#   a docker volume is recommended.  See the DBF_EXTENT_NAMES amd
#   STN_TRAN_LOG_DIRECTORIES variables in system.conf.
#      

# note that the user name gsadmin must be the same as the one in the
# runGemstone script included in this directory.
RUN useradd gsadmin -m -u 32765 -g users


RUN mkdir /gemstone
RUN chown gsadmin:users /gemstone

RUN mkdir /opt/gemstone
RUN chown gsadmin:users /opt/gemstone

COPY services /gemstone
RUN cat /gemstone/services >>/etc/services && rm /gemstone/services

WORKDIR /gemstone
RUN wget --progress=dot https://downloads.gemtalksystems.com/pub/GemStone64/3.6.1/GemStone64Bit3.6.1-x86_64.Linux.zip
RUN unzip GemStone64Bit3.6.1-x86_64.Linux.zip \
        && chown -R gsadmin:users /gemstone \
        && rm GemStone64Bit3.6.1-x86_64.Linux.zip

# Create the /gemstone-keys directory and copy the community starter
# key there.
RUN mkdir /gemstone-keys \
        && cp /gemstone/GemStone64Bit3.6.1-x86_64.Linux/sys/community.starter.key  /gemstone-keys/gemstone.key \
        && chown -R gsadmin:users /gemstone-keys

# Copy our configuration file
COPY --chown=gsadmin:users system.conf /gemstone/GemStone64Bit3.6.1-x86_64.Linux/data

RUN mkdir /gemstone-data && chown gsadmin:users /gemstone-data

USER gsadmin

COPY bashrc bashrc
RUN cat bashrc >>/home/gsadmin/.bashrc && rm bashrc

ENV GEMSTONE=/gemstone/GemStone64Bit3.6.1-x86_64.Linux

WORKDIR /gemstone/GemStone64Bit3.6.1-x86_64.Linux/install
RUN ./installgs

RUN cp -p /gemstone/GemStone64Bit3.6.1-x86_64.Linux/data/extent0.dbf /gemstone-data

WORKDIR /gemstone
COPY runGemstone /gemstone

# Note that this is the same as the port number in services file
EXPOSE 40055

CMD ./runGemstone
