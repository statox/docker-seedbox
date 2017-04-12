## Install seedbox system for several users with
##    Transmission
##    Sonarr
##    Headphones
##
## Debian 8

# References:
#   DOCKER INSTALL                - https://docs.docker.com/engine/installation/linux/debian/
#   SHIPYARD (docker management)  - https://github.com/shipyard/shipyard
#   DOCKER TRANSMISSION           - https://hub.docker.com/r/dperson/transmission/
#   DOCKER SONARR                 - https://hub.docker.com/r/linuxserver/sonarr/
#   DOCKER HEADPHONES             - https://hub.docker.com/r/linuxserver/headphones/

# TODO
# Shipyard
#   See how to use -disable-usage-info to disable anonymous report
#   Add variables to change credentials
# Transmission
#   Add variables to change credentials
# Sonar
#   Change permissions to /downloads
#   Add variables to change credentials
#   Check how to automatically configure transmission
#   Check how to automatically configure providers
# Hearphones
#   Change permissions to /downloads
#   Add variables to change credentials
#   Check how to automatically configure transmission
#   Check how to automatically configure providers

# TODO other tools to install
#   PROXY T411    - https://github.com/KiLMaN/T411-Torznab
#   SICKBEARD     - https://hub.docker.com/r/linuxserver/sickbeard/
#   COUCH POTATO  - https://hub.docker.com/r/linuxserver/couchpotato/

function installCore() {
    echo "Installing docker"
    installDocker

    echo "Installing docker-compose"
    installCompose

    echo "Installing Shipyard"
    installShipyard
}
function installDocker() {

    apt-get -y install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get -y update
    apt-get -y install docker-ce

}

function installCompose() {
    curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

function installShipyard() {
    curl -s https://shipyard-project.com/deploy | bash -s
}

function installNewUser() {
    HOME=/home/seed/$USER
    mkdir $HOME
    cp docker-compose.yml $HOME
    cd $HOME
    docker-compose up
}

USER=user1

installCore
installNewUser
