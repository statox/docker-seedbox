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
    docker network create -d bridge --subnet 172.25.0.0/16 network-$USER

    installTransmission
    installHeadphones
    installSonarr
    installMuximux

    echo "New docker containers installed"
    echo "Shipyard:     http://hostname:8080"
    echo "Transmission: http://hostname:"$PORT_TRANSMISSION
    echo "Sonarr:       http://hostname:"$PORT_SONARR
    echo "Headphones:   http://hostname:"$PORT_HEADPHONES
    echo "Muximux:      http://hostname:"$PORT_MULTIMUX
}

function installMuximux() {
    docker create \
        --name=muximux-$USER \
        -v $CONFIG_MUXIMUX:/config \
        -e PGID=1001 -e PUID=1001  \
        -e TZ=europe -p $PORT_MULTIMUX:80 \
        linuxserver/muximux

    docker network connect network-$USER muximux-$USER

    docker start muximux-$USER
}

function installSonarr() {
    # Change transmission settings
    # Set download directory to /downloads

    docker create \
        --name sonarr-$USER \
        -p $PORT_SONARR:8989 \
        -e PUID=1001 -e PGID=1001 \
        -v /dev/rtc:/dev/rtc:ro \
        -v $CONFIG_SONARR:/config \
        -v $DOWNLOADS/series:/tv \
        -v $DOWNLOADS:/downloads \
        linuxserver/sonarr

    docker network connect network-$USER sonarr-$USER

    docker start sonarr-$USER
    docker exec sonarr-$USER chmod 777 /downloads/
}

function installTransmission() {
    docker create \
        --name=transmission-$USER \
        -v $CONFIG_TRANSMISSION:/config \
        -v $DOWNLOADS:/downloads \
        -v $WATCH_TRANSMISSION:/watch \
        -e PGID=1001 -e PUID=1001 \
        -e TZ=Europe \
        -p $PORT_TRANSMISSION:9091 \
        -p $PORT_TRANSMISSION_SEED:51413 \
        -p $PORT_TRANSMISSION_SEED:51413/udp \
        linuxserver/transmission

    docker network connect network-$USER transmission-$USER

    docker start transmission-$USER

    ## Enable authentication
    #docker exec transmission-$USER \
    #sed \
    #    -i /config/settings.json \
    #    -e '/rpc-authentication-required/s/false/true/' \
    #    -e '/rpc-password/s/:\s".*"/: "'$USER'"/' \
    #    -e '/rpc-username/s/""/"'$USER'"/'
}

function installHeadphones() {
    # Set download directory to /var/lib/transmission-daemon/Downloads

    docker create \
        --name  headphones-$USER  \
        -v $CONFIG_HEADPHONES:/config \
        -v $DOWNLOADS:/downloads \
        -v $DOWNLOADS/music:/music \
        -e PGID=1001 -e PUID=1001 \
        -e TZ=Europe \
        -p $PORT_HEADPHONES:8181 \
        linuxserver/headphones

    docker network connect network-$USER headphones-$USER

    docker start headphones-$USER
    docker exec headphones-$USER chmod 777 /downloads/

    #docker exec headphones-$USER \
    #sed \
    #    -i /config/config.ini \
    #    -e '/download_torrent_dir/s/$/\/downloads\/music/' \
    #    -e '/http_username/s/$/'$user'/' \
    #    -e '/http_password/s/$/'$user'/' \
    #    -e '/oldpiratebay/s/0/1/' \
    #    -e '/piratebay/s/0/1/' \
    #    -e '/mininova/s/0/1/' \
    #    -e '/transmission_password/s/$/'$user'/' \
    #    -e '/transmission_username/s/$/'$user'/' \
    #    -e '/transmission_host/s/$/http:\/\/transmission-'$user':9091/' \
    #    -e '/numberofseeders/s/10/1/'
}

# Variable definitions
USER=seedalpha
HOME=/home/seed/$USER

DOWNLOADS=$HOME/torrents

PORT_MULTIMUX=8000
PORT_TRANSMISSION=9000
PORT_TRANSMISSION_SEED=51413
PORT_SONARR=9001
PORT_HEADPHONES=9002

CONFIG_MUXIMUX=/etc/$USER/multimux
CONFIG_TRANSMISSION=/etc/$USER/transmission
CONFIG_SONARR=/etc/$USER/sonarr
CONFIG_HEADPHONES=/etc/$USER/headphones

WATCH_TRANSMISSION=$HOME/watch

installCore
#installNewUser
#startUserConstainer
