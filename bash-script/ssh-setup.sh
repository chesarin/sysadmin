#/usr/bin/env bash
setup()
{
    user=$1
    su - ${user}
    echo "Creating Keys for user $(whoami)"
    echo ${HOME}
    rm -f ${HOME}.ssh/id_rsa ${HOME}.ssh/id_rsa.pub ${HOME}/.ssh/known_hosts
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
}

setup app
