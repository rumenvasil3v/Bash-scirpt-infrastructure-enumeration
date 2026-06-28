#!/bin/bash

if [ $# -ne 4 ];
then 
    echo "Illegal number of arguments"
    echo "Usage: infrastructure-enumeration <domain name> <file name for subdomain list> <file name for ip addresses> <dns records file name>"
    exit 1
fi

domain=$1
subdomainfilename=$2
ipaddressfilename=$3
dnsrecordsfilename=$4

# certificate transperancy
curl -s https://crt.sh/\?q\="$domain"\&output\=json | jq .

# filter by unique subdomains
curl -s https://crt.sh/\?q\="$domain"\&output\=json | jq . | 
  grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/, "\n");}1;' | sort -u > $subdomainfilename

# identifying hosts directly accessible from the internet and not hosted by third-party providers, because I am not allowed to test these hosts without the permission of third-party providers

for i in $(cat '$subdomainfilename');
do 
  host $i | grep "has address" | grep $domain | cut -d" " -f1,4;
done

for i in $(cat '$subdomainfilename');
do
  host $i | grep "has address" | grep $domain | cut -d" " -f4 > $ipaddressfilename;
done

shodan init f2hJU9i58SMnaaGUi6M39dDgja8Ffwpf

for i in $(cat '$ipaddressfilename');
do
  shodan host $i;
done

# now displaying all DNS records where I might find more hosts
dig any inlanefreight.com > $dnsrecordsfilename 

