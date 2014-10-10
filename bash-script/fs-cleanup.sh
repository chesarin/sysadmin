#!/usr/bin/env bash
cleanup()
{
    # echo $(pwd)
    # echo $(whoami)
    cd /home/deployer
    find war -type f -name '*.war' -delete
    rm -rf web/www web/goahead
    rm -rf pSFcruft
    rm -rf publisherStaticFiles/*
    rm -rf web-maintenance/* web-redirects/*
    cd /home/postgres
    rm -rf yaz5.0_database
    su - postgres
    cvs checkout 'yaz5.0_database'
}
cleanup
