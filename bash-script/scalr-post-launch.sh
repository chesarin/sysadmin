#/usr/bin/env bash
user=$1
client=$2
domain_name=$3
servers=(fs-primary icat front cart ws) 
test () 
{
 for server in ${servers[@]};
   do echo 'ext-'$client'-'$server'.'$client'.'$domain_name;
 done
}
membase_pass()
{
 #create membase password and store it on fs-primary server
 fs_server='ext-'$client'-'fs-primary'.'$client'.'$domain_name
 pass=$(mkpasswd -l 16 -s 0)
 ssh $user@$fs_server 
}
ssh_creation()
{
    host=$1
    dest_user=$2
    echo "$host $dest_user"
    # ssh -i ${HOME}/.ssh/identities/${client}.pem ${user}@${host} "sudo ${dest_user} -c "whoami" "  
}
ssh_manager()
{
    for server in ${servers[@]};
    # do echo 'ext-'$client'-'$server'.'$client'.'$domain_name;
    do ssh_creation ${server} app;
    done
}
ssh_manager

