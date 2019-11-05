# Gemstone in Docker

GemStone is a powerful object-oriented database management system.
See the [GemTalk Systems home page](https://gemtalksystems.com/) for
more information.

This repository contains files that can be used and extended to build
a [docker](https://www.docker.com/) container to run GemStone.

## Getting started

1. Clone this repository
2. Download
[GemStone64Bit3.5.0-x86_64.Linux.zip](https://gemtalksystems.com/products/gs64/versions35x/)
from the GemTalk web site and place it in the directory created when
you cloned this repository.
3. Build a docker image with

        docker build . -t gemstone

4. Run the docker image in a container with

        docker run -it -p 40055:40055 --shm-size 1G gemstone

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


## Viewing logs

To view the gemstone logs first find your gemstone docker container id:

    > docker container ls | grep gemstone
    8922a14116d0        gemstone            "/bin/sh -c ./runGem…"   2 minutes ago       Up 2 minutes        0.0.0.0:40055->40055/tcp   mystifying_babbage
    
then use `cat` or `tail` to view the log:

    > docker exec 8922a14116d0 cat /gemstone/GemStone64Bit3.5.0-x86_64.Linux/data/gs64stone.log

## Persistent data

If you run the database as described above, your will disappear as
soon as you stop the container.  This is typical of docker-based
systems.  We need to provide persistent storage to the container so
that your database can persist between runs.

The supplied `Dockerfile` creates a directory /gemstone-data and
places a single extent file in that directory.  The configuration file
`system.conf` specifies that this directory should be used to store
all persistent GemStone data.  To persist data between invocations you
can:
* Use docker volumes -- this is probably the best way to maintain your
  development database in a local docker volume.
* Create permanent storage through your cloud provider and "mount" it
  at that location.

These options are described below.

### Storing data in a docker volume

Create the volume:

    docker volume create gemstone-vol
    docker run -it --rm --mount source=gemstone-vol,target=/gemstone-data gemstone /bin/bash
    > cp ${GEMSTONE}/data/extent0.dbf /gemstone-data
    > exit
        
Whenever you run your gemstone server, specify the that the volume
must be mounted:

    docker run -it --rm --mount source=gemstone-vol,target=/gemstone-data gemstone
    
Note that you can access this volume in any docker container by
mounting the volume when you launch the container.
    
### Storing data in cloud provider's volume

This process depends on your cloud provider.  The steps are typically:

1. Allocate a persistent volume with ample size for your database.
2. Attach the volume to a "compute instance" of some kind.
3. Copy the default extent0.db file to the volume
4. Make sure that when your gemstone containers are launched by your provider, you have the volume mounted in the correct place on the compute instance and within the container.

I will try to provide concrete examples when time permits.

### GemStone system configuration

You can modify the `system.conf` file to suit your needs.
Documentation is availble in the System Administration manual on the
[GemStone web
site](https://gemtalksystems.com/products/gs64/versions35x/).

### Using a non-community key file

The `Dockerfile` included in this repository builds an image that
includes the GemStone community edition license (included when you
downloaded the zip file above).  If you would like to build a docker
image that uses a different key file, you can create a separate
`Dockerfile` like:

    FROM gemstone:latest
    
    USER gsadmin
    COPY --chown=gsadmin:users gemstone.key /gemstone-keys

Note that this `Dockerfile` assumes that you tagged the base GemStone
docker image using the name `gemstone`.

### Using a "secret" for your key file

Most cloud platforms support secure storage of "secrets."  Examples:
[Docker Swarm secrets](https://docs.docker.com/engine/swarm/secrets/),
[Kubernetes
secrets](https://kubernetes.io/docs/concepts/configuration/secret/),
[AWS secrets](https://aws.amazon.com/secrets-manager/).  [GCP secrets
management](https://cloud.google.com/solutions/secrets-management/)

If you prefer to place your GemStone key file in one of those secrets
systems, you simply need to make sure that the key is available as
`/gemstone-keys/gemstone.key` when the gemstone container starts.  Most
of these secrets management systems provide a way to "mount" your
secrets inside the container.

