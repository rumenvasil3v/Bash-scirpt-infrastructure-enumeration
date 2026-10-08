# Bash-scirpt-infrastructure-enumeration

A small bash script I wrote to practise the first phase of infrastructure enumeration: given a company's domain, work out which hosts are actually reachable from the internet and which ones belong to the company rather than to some third-party provider.

I kept the "third-party" distinction on purpose. You can't test a host that sits on someone else's infrastructure without that provider's permission, so the script only follows hosts whose address record resolves under the target domain itself.

## What it does

It runs in four steps.

1. Asks crt.sh (certificate transparency logs) for every certificate issued for the domain, and boils the JSON down to a sorted list of unique hostnames.
2. Runs `host` on each of those names and keeps only the ones that have an A record and contain the domain, printing the hostname and its IP.
3. Writes the IPs to a file and runs `shodan host` on each one to see what the internet already knows about them.
4. Pulls the domain's DNS records with `dig any`, since TXT, MX and NS entries often point at more hosts and at the providers behind them.

## Usage

```
./script/infrastructure_enumeration.sh <domain> <subdomain file> <ip file> <dns records file>
```

For example:

```
./script/infrastructure_enumeration.sh inlanefreight.com subdomainlist ip-addresses.txt dnsrecords
```

All four arguments are required, otherwise it prints the usage line and exits.

You'll need `curl`, `jq`, `host`, `dig` and the Shodan CLI (`pip install shodan`), plus a Shodan account. Run `shodan init <your key>` once before using the script.

Only point this at domains you own or have written permission to test.

## What's in the repo

- `script/` has the script itself.
- `concepts/dnsrecords_type_meaning` is my own cheat sheet on what A, MX, NS and TXT records tell you.
- `domain_inlanefreight_info/` holds output from my test runs against inlanefreight.com: the subdomain lists, the IP found (134.209.24.248), and the raw `dig` output. There are a few `subdomainlist` variants because I kept re-running it while fixing things.

## Rough edges

It's a learning project and it shows in a few places:

- The `dig` call at the bottom is hardcoded to inlanefreight.com instead of using the domain argument.
- The loops that read the subdomain and IP files wrap the variable in single quotes, so bash doesn't expand it. That's also why odd files literally named `$subdomainfilename` and `$ipaddressfilename` ended up in the sample output folder.
- The IP loop uses `>` inside the loop, so each pass overwrites the file and you only keep the last address. `>>` or redirecting after `done` would fix it.
- The Shodan `init` line is meant to be run once by hand, not on every run of the script.
