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
    curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

function installShipyard() {
    curl -s https://shipyard-project.com/deploy | bash -s
}

function installNewUser() {
    echo "Enter the new of the new user"
    read USER

    # Create the home directory
    HOME=/home/seed/$USER
    mkdir -p $HOME
    cp docker-compose.yml $HOME

    # Create the containers and their configuration files
    cd $HOME
    docker-compose up -d
    docker-compose stop

    # Change transmission
    sed -i '/rpc-authentication-required/s/false/true/' ./etc/transmission/settings.json
    sed -i '/rpc-username/s/""/"' $USER '"/'        ./etc/transmission/settings.json
    sed -i '/rpc-password/s/:.*/: "' $USER '",/'    ./etc/transmission/settings.json
}

function startUserContainers() {
    cd $HOME
    docker-compose up -d
}


installCore
installNewUser
startUserContainers
