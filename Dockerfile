FROM ubuntu:latest
RUN apt update && apt install -y inetutils-ping unzip rpcbind

# Notes:
#
#   copy your GemStone key file into this directory.  Call it
#   gemstone.key.
#
#   download and copy GemStone64Bit3.5.0-x86_64.Linux.zip to this
#   directory.
#
#   gemstone data volume should be mounted at /gemstone/data.
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

COPY GemStone64Bit3.5.0-x86_64.Linux.zip /gemstone
WORKDIR /gemstone
RUN unzip GemStone64Bit3.5.0-x86_64.Linux.zip && chown -R gsadmin:users /gemstone

# Create the /gemstone-keys directory and copy the community starter
# key there.
RUN mkdir /gemstone-keys && \
        cp /gemstone/GemStone64Bit3.5.0-x86_64.Linux/sys/community.starter.key \
        /gemstone-keys/gemstone.key && \
        chown -R gsadmin:users /gemstone-keys

# Copy our configuration file
COPY --chown=gsadmin:users system.conf /gemstone/GemStone64Bit3.5.0-x86_64.Linux/data

RUN mkdir /gemstone-data && chown gsadmin:users /gemstone-data

USER gsadmin

COPY bashrc bashrc
RUN cat bashrc >>/home/gsadmin/.bashrc && rm bashrc

ENV GEMSTONE=/gemstone/GemStone64Bit3.5.0-x86_64.Linux

WORKDIR /gemstone/GemStone64Bit3.5.0-x86_64.Linux/install
RUN ./installgs

RUN cp -p /gemstone/GemStone64Bit3.5.0-x86_64.Linux/data/extent0.dbf /gemstone-data

WORKDIR /gemstone
COPY runGemstone /gemstone

# Note that this is the same as the port number in services file
EXPOSE 40055

CMD ./runGemstone
