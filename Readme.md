GemStone is a powerful object-oriented database management system.
See [GemTalk Systems home page](https://gemtalksystems.com/) for more
information.

This repository contains files that can be used and extended to build
a [docker](https://www.docker.com/) container to run GemStone.

To use:

1. Download
[GemStone64Bit3.5.0-x86_64.Linux.zip](https://gemtalksystems.com/products/gs64/versions35x/)
from the GemTalk web site
2. Build the docker image with

        docker build . -t gemstone

3. Run the docker image in a container with

        docker run -it -p 40055:40055 gemstone

If all goes well you should see something like:

    startnetldi[Info]: GemStone version '3.5.0'
    startnetldi[Info]: Starting GemStone network server 'gs64ldi'.
    startnetldi[Info]: GEMSTONE is: '/gemstone/GemStone64Bit3.5.0-x86_64.Linux'.
    [Info]: Loaded /gemstone/GemStone64Bit3.5.0-x86_64.Linux/lib/libnetldi-3.5.0-64.so
    startnetldi[Info]: Log file is '/opt/gemstone/log/gs64ldi.log'.
    startnetldi[Info]: GemStone server 'gs64ldi' has been started, process 8
    startstone[Info]: GemStone version '3.5.0'
    startstone[Info]: Starting Stone repository monitor gs64stone.
    startstone[Info]: GEMSTONE is: '/gemstone/GemStone64Bit3.5.0-x86_64.Linux'.
    startstone[Info]:
      GEMSTONE_SYS_CONF=/gemstone/GemStone64Bit3.5.0-x86_64.Linux/data/system.conf
      GEMSTONE_EXE_CONF=/gemstone/gs64stone.conf
    stoned[Info]: Log file is '/gemstone/GemStone64Bit3.5.0-x86_64.Linux/data/gs64stone.log'.
    startstone[Info]: GemStone server gs64stone has been started, process 10
    Status        Version    Owner     Started     Type       Name
    -------      --------- --------- ------------ ------      ----
    OK           3.5.0     gsadmin   Nov 05 19:35 Netldi      gs64ldi
    OK           3.5.0     gsadmin   Nov 05 19:35 Stone       gs64stone
    OK           3.5.0     gsadmin   Nov 05 19:35 cache       gs64stone~533fe7e9ef943228
    Sleeping...

