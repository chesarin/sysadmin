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
    # command='whoami && hostname'
    # ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo -u ${dest_user} whoami && hostname"  
    # ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo -u ${dest_user} $command"  
    command='rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/known_hosts && ssh-keygen -t rsa'
    ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo su - ${dest_user} -c ${command}"  

}
ssh_manager()
{
    local servers=(icat front cart ws) 
    for server in ${servers[@]};
    do 
	server="ext-${client}-${server}.${client}.${domain_name}"
	# echo $server
	ssh_creation ${server} app;
    done
}
ssh_manager

