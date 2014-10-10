#!/usr/bin/env bash
cleanup()
{
    # echo $(pwd)
    # echo $(hostname)
    cd /home/app
    rm -rf instance/logs/*
    find instance/webapps -type f -delete
    rm -f appsToDeploy/*.war*
}
cleanup
