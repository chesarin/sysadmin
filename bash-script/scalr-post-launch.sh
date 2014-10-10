#!/usr/bin/env bash
user=$1
client=$2
domain_name=$3
servers=(fs-primary icat front cart ws) 
ssh_command='ssh -oStrictHostKeyChecking=false -oUserKnownHostsFile=/dev/null'
ssh_param="-i ${HOME}/.ssh/identities/${client}java.pem -t"
cleanup()
{
    local host=${1}
    if [[ "${host}" =~ .*fs-primary.* ]]; then
	echo "fs-primary ${host} cleanup"
	local my_script=$(base64 -w0 fs-cleanup.sh)
	${ssh_command} ${ssh_param} ${user}@${host} "echo ${my_script} | base64 -d | bash"
    elif [[ "${host}" =~ .*icat.* || "${host}" =~ .*front.* || "${host}" =~ .*cart.* ]]; then
	local my_script=$(base64 -w0 app-cleanup.sh)
	echo "host applications ${host} cleanup"
	${ssh_command} ${ssh_param} ${user}@${host} "echo ${my_script} | base64 -d | bash"
    elif [[ "${host}" =~ .*ws.* ]]; then
	echo "ws server ${host} cleanup"
	# ${ssh_command} ${ssh_param} ${user}@${host} 'pwd ; hostname'
	${ssh_command} ${ssh_param} ${user}@${host} 'rm -rf /var/www/www/htdocs/* /var/www/goahead/htdocs/*'
    fi
}
test() 
{
    for server in ${servers[@]};
    do 
	echo 'ext-'$client'-'$server'.'$client'.'$domain_name;
    done
}
create_pass()
{
    local pass=$(mkpasswd -l 16 -s 0)
    echo "${pass}"
}
membase_pass()
{
#create membase password and store it on fs-primary server
    # fs_server='ext-'$client'-'fs-primary'.'$client'.'$domain_name
    local host=$1
    local pass=$2
    local membase_file='/root/scripts/membase-password'
    # local fs_server=${1}
    if [[ "${host}" =~ .*fs-primary.* ]];then
	echo "Creating membase server for ${host} with password ${pass}"
	# echo "${host} FS Host"
	echo "The password for membase is ${pass} and we are overwritting ${membase_file} on ${host}"
	local svn_up='svn up /root/scripts/java-cloud-scripts'
	local membase_init='/root/scripts/java-cloud-scripts/initialize-membase'
	${ssh_command} -i ${HOME}/.ssh/identities/${client}java.pem ${user}@${host} "echo ${pass} > ${membase_file} && ${svn_up} && ${membase_init}"  
    else
	echo "Configuring membase client ${host} with ${pass}"
	local build_membase_config='/root/scripts/java-cloud-scripts/buildmembaseconfig'
	local start_moxi='/etc/init.d/moxi-server restart'
	${ssh_command} -i ${HOME}/.ssh/identities/${client}java.pem ${user}@${host} "echo ${pass} > ${membase_file} && ${build_membase_config} && ${start_moxi}" 
    fi
    echo 'Membase setup completed'
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
    
    # command='rm -i ${HOME}/.ssh/id_rsa ${HOME}/.ssh/id_rsa.pub ${HOME}/.ssh/known_hosts && ssh-keygen -t rsa'
    
# ssh ${options} -i ${HOME}/.ssh/identities/${client}.pem -t ${user}@${host} 'sudo su - ${dest_user} -c ${command}'  
    
    ssh ${options} -i ${HOME}/.ssh/identities/${client}java.pem -t ${user}@${host} "echo ${my_script} | base64 -d | su - ${dest_user} -c bash"  
    
}
ssh_manager()
{
    local servers=(fs-primary icat front cart ws) 
    # local pass=$(create_pass)
    for server in ${servers[@]};
    do 
	if [ ${server} !=  'fs-primary' ]; then
	    server="ext-${client}-${server}.${client}.${domain_name}"
	    # echo "doing $server work"
	    # test1 ${server} app;
	    # test1 ${server} ${user}
	    # membase_pass ${server} ${pass}
	    cleanup ${server}
	else
	    server="ext-${client}-${server}.${client}.${domain_name}"
	    # echo $server
	    # test1 ${server} deployer
	    # test1 ${server} postgres
	    # membase_pass ${server} ${pass}
	    cleanup ${server}
	fi
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
