#!/bin/bash

domain=$1

# certificate transperancy
curl -s https://crt.sh/\?q\="$domain"\&output\=json | jq .

# filter by unique subdomains
curl -s https://crt.sh/\?q\="$domain"\&output\=json | jq . | 
  grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/, "\n");}1;' | sort -u > subdomainlist

# identifying hosts directly accessible from the internet and not hosted by third-party providers, because I am not allowed to test these hosts without the permission of third-party providers

for i in $(cat subdomainlist);do host $i | grep "has address" | grep $domain | cut -d" " -f1,4;done

