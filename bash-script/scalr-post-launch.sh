#/usr/bin/env bash
user=$1
client=$2
domain_name=$3
servers=(fs-primary icat front cart ws) 
ssh_command='ssh -oStrictHostKeyChecking=false -oUserKnownHostsFile=/dev/null'
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
    local membase_file='/root/scripts/membase-password'
    echo "Creating membase password and storing it on ${fs_server}"
    # local fs_server=${1}
    pass=$(mkpasswd -l 16 -s 0)
    echo "The password for membase is ${pass} and we are overwritting ${membase_file}"
    local svn_up='svn up /root/scripts/java-cloud-scripts'
    local membase_init='/root/scripts/java-cloud-scripts/initialize-membase'
    ${ssh_command} -i ${HOME}/.ssh/identities/${client}java.pem ${user}@${fs_server} "echo ${pass} > ${membase_file} && ${svn_up} && ${membase_init}"  
    echo 'membase setup completed'
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
    command='rm -i ${HOME}/.ssh/id_rsa ${HOME}/.ssh/id_rsa.pub ${HOME}/.ssh/known_hosts && ssh-keygen -t rsa'
    ssh ${options} -i ${HOME}/.ssh/identities/${client}java.pem -t ${user}@${host} 'sudo su - ${dest_user} -c ${command}'  

}
test1()
{
    host=$1
    dest_user=$2
    local my_script=$(base64 -w0 ssh-setup.sh)
    echo "Creating SSH keys on $host as user $dest_user"
    options='-oStrictHostKeyChecking=false -oUserKnownHostsFile=/dev/null'
    # command='whoami && hostname'
    # ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo -u ${dest_user} whoami && hostname"  
    # ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} "sudo -u ${dest_user} $command"  
    command='rm -i ${HOME}/.ssh/id_rsa ${HOME}/.ssh/id_rsa.pub ${HOME}/.ssh/known_hosts && ssh-keygen -t rsa'
    # ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} 'sudo su - ${dest_user} -c ${command}'  
    ssh ${options} -i ${HOME}/.ssh/identities/${client}java.pem -t ${user}@${host} 'echo ${my_script} | base64 -d | su - app -c bash'  
    
}
ssh_manager()
{
    local servers=(icat front cart ws) 
    for server in ${servers[@]};
    do 
	server="ext-${client}-${server}.${client}.${domain_name}"
	# echo $server
	# ssh_creation ${server} app;
	test1 ${server} app;
    done
}
fix_szradm()
{
    #Fixing szradm to activate environment variables
    #on Scarl
    if [ ! -e '/usr/local/bin/szradm' ]; then
	echo 'fixing szradm';
	cd /usr/local/bin ;
	ln -s /usr/bin/szradm .;
	/usr/local/bin/regen-scalr;
   fi
}
ssh_manager
# membase_pass
