# docker-seedbox
Automatic seedbox creation with docker

## Tools installed
These tools are automatically installed by the script at the first run

 - [Docker engine](https://docs.docker.com/engine/installation/linux/debian/)
 - [Docker-compose](https://docs.docker.com/compose/install/)
 - [Shipyard](https://github.com/shipyard/shipyard)

## Containers installed
These containers can be created for each user.

 - [Transmission](https://hub.docker.com/r/linuxserver/transmission/) P2P download client
 - [Sonarr](https://hub.docker.com/r/linuxserver/sonarr/) TV shows indexer
 - [Headphones](https://hub.docker.com/r/linuxserver/headphones/) Music indexer
 - [couchpotato](https://hub.docker.com/r/linuxserver/couchpotato/) Films indexer

## TODO

- Shipyard
    - See how to use `-disable-usage-info` to disable anonymous report
    - Add variables to change credentials
- Transmission
    - Add variables to change credentials
- Sonar
    - Add variables to change credentials
    - Check how to automatically configure transmission
    - Check how to automatically configure providers
- Headphones
    - Add variables to change credentials
    - Check how to automatically configure transmission
    - Check how to automatically configure providers

- Other tools to install
    - [T411-Torznab](https://github.com/KiLMaN/T411-Torznab)
    - [Sickbeard](https://hub.docker.com/r/linuxserver/sickbeard/)
    - [Jackett](https://hub.docker.com/r/linuxserver/jackett/)
