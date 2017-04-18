#!/bin/bash

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
    curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-"$(uname -s)"-"$(uname -m)" > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

function installShipyard() {
    curl -s https://shipyard-project.com/deploy | bash -s
}

function installNewUser() {
    echo "Enter the new of the new user"
    read -r USER

    # Create the home directory
    HOME=/home/seed/$USER
    mkdir -p "$HOME"
    cp docker-compose.yml "$HOME"

    # Create the containers and their configuration files
    cd "$HOME" || exit
    docker-compose up -d

    echo "Waiting for the containers to start"
    while
        [ ! -f ./etc/headphones/config.ini ] \
        || [ ! -f ./etc/transmission/settings.json ] \
        || [ ! -f ./etc/couchpotato/config.ini ]
    do
        echo "."
        sleep 2
    done

    docker-compose stop

    # Change transmission configuration
    sed -i '
    /rpc-authentication-required/s/false/true/
    /rpc-username/s/""/"'"$USER"'"/
    /rpc-password/s/:.*/: "'"$USER"'",/
    ' ./etc/transmission/settings.json

    # Change headphones configuration
    sed -i '
    /transmission_host/s/""/http:\/\/transmission:9091/
    /transmission_user/s/""/'"$USER"'/
    /transmission_password/s/""/'"$USER"'/
    /download_torrent_dir/s/""/\/var\/lib\/transmission-daemon\/Downloads/
    /torrent_downloader/s/0/1/

    /http_username/s/""/'"$USER"'/
    /http_password/s/""/'"$USER"'/

    /numberofseeders/s/10/2/

    /oldpiratebay/s/0/1/
    /piratebay/s/0/1/
    /mininova/s/0/1/
    ' ./etc/headphones/config.ini

    # Change couchpotato configuration
    # (We have to use awk because of the format of the config file)
    awk -v USER="$USER" '
        BEGIN {
            RS="";
            FS="\n";
            ORS="\n\n";
        }
        {
            if ($1 == "[core]") {
                sub("username = ", "username = "USER, $0)
                sub("[^_]password = ", "\npassword = "USER, $0)
                sub("show_wizard = 1", "show_wizard = 0", $0)

            } else if ($1 == "[transmission]") {
                sub("username =", "username = "USER, $0)
                sub("enabled = 0", "enabled = 1", $0)
                sub("localhost", "transmission", $0)
                sub("directory = ", "directory = /var/lib/transmission-daemon/Downloads/", $0)
                sub("remove_complete = True", "remove_complete = False", $0)
                sub("password = ", "password = "USER, $0)
            } else if ($1 == "[rarbg]") {
                sub("enabled = False", "enabled = True", $0)
                sub("min_seeders = 10", "min_seeders = 1", $0)
            } else if ($1 == "[rarbg]") {
                sub("enabled = False", "enabled = True", $0)
            } else if ($1 == "[searcher]") {
                sub("french, ", "", $0)
            }

            print $0
        }
    ' ./etc/couchpotato/config.ini > ./etc/couchpotato/config.ini.tmp
    #mv ./etc/couchpotato/config.ini.tmp ./etc/couchpotato/config.ini
}

function startUserContainers() {
    cd "$HOME" || exit
    docker-compose up -d
}


installCore
installNewUser
startUserContainers
