![CI Workflow](https://github.com/boston-library/ark-manager/actions/workflows/build-no-docker.yaml)![Build Status](https://github.com/boston-library/ark-manager/actions/workflows/build-no-docker.yaml/badge.svg)

## Ark Manager Version 2

A lightweight API that manages the creation of ARKs([Archival Resource Keys](https://en.wikipedia.org/wiki/Archival_Resource_Key) as well as redirection to the objects associated with them.

# Docker

To use the docker container run simply use `docker-compose up [-d for running in the background]`

The `entrypoint.sh` script will setup the databases for you.

To rebuild the docker container use `docker-compose build --no-cache`
