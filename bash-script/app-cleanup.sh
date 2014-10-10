#!/usr/bin/env bash
cleanup()
{
    cd /home/app
    rm -rf instance/logs/*
    find instance/webapps -type f -delete
    rm -f appsToDeploy/*.war*
}
cleanup
