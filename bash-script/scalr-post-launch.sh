#/usr/bin/env bash
user=$1
client=$2
domain_name=$3
test () 
{
 servers=(fs-primary icat front cart ws) 
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
test
