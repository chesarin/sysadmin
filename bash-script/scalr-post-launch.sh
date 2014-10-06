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
    echo "Creating SSH keys on $host as user $dest_user"
    options='-oStrictHostKeyChecking=false -oUserKnownHostsFile=/dev/null'
    ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo -u ${dest_user} whoami && hostname"  
}
ssh_manager()
{
    fs_server=(fs_primary)
    for server in ${servers[@]/$fs_server};
    do 
	server="ext-${client}-${server}.${client}.${domain_name}"
	ssh_creation ${server} app;
    done
}
ssh_manager

