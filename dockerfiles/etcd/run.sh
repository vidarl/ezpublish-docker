#!/bin/bash

set -e

if [ ! -f /volumes/etcd/etcd_0.4.6_amd64.deb ]; then
    cp /tmp/etcd_0.4.6_amd64.deb /volumes/etcd/
fi

if [ "aa$START_ETCD" == "aayes" ]; then
    discovery=$ETCD_DISCOVERY

    if [ "aa$discovery" == "aaautogenerate" ]; then
        discovery=`curl -s https://discovery.etcd.io/new`
    fi

    # We'll not change discovery URL and other settings if etcd has previously been started in this container
    if [ ! "$(ls -A /var/lib/etcd/)" ]; then
        echo Writing discovery URL and name to etcd.conf
        perl -pi -e "s@^(discovery.*= \")(.*\")@\1$discovery\"@" /etc/etcd/etcd.conf
        perl -pi -e "s@^(name.*= \")(.*\")@\1$ETCD_NAME\"@" /etc/etcd/etcd.conf
    fi

    # Have to unset ETCD_DISCOVERY. Turns out the existence if that env variable will override any value defined in config file
    unset ETCD_DISCOVERY
    etcd --config=/etc/etcd/etcd.conf
fi
