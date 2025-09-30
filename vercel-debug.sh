#!/bin/bash
# Run these commands from the affected/problematic network
# Once completed, send the file to Vercel support

# Ask for domain and don't accept no domain
# Also, we need to ensure not to pass an URL (https://example.com/path) 
# rather than only the domain name
domain=""
while [[ -z "$domain" || "$domain" =~ '/' ]]
do
  echo "Domain to test (e.g. example.com): "
  read domain </dev/tty
done

# Lookup the DNS record to return the IP Ranges
echo "┌───────────────────────────────────────"
echo "├─────── Fetching IP Addresses"
echo "│" 
# Make curl request to the IP Range Lookup API
ip_addresses=$(curl -s -X POST "https://ip-ranges.vercel.support" -d "${domain}")
# Check if API call failed, returned empty, or returned special error responses
# If any of these conditions are true, exit immediately without running tests
if [ $? -ne 0 ] || [ -z "$ip_addresses" ] || [ "$ip_addresses" = "Not on Vercel" ] || [ "$ip_addresses" = "DNS lookup failed" ]; then
    echo "│ Range lookup failed - ${ip_addresses:-No response from API}"
    echo "└───────────────────────────────────────"
    echo ""
    exit 0
else
    echo "│ ${domain} IP range: $ip_addresses"
    echo "└───────────────────────────────────────"
    echo ""
    # Parse response and convert to array
    ip_range=($(echo "$ip_addresses" | tr ',' ' '))
fi

# Measure time 
start=$(date +%s)

echo "┌───────────────────────────────────────"
echo "├─────── STARTING"
echo "│" 
# Show affected domain
echo "│ Domain to test: ${domain} "
# Capture time/date
echo "│ Timestamp (UTC): $(date -u)"
echo "│ Timestamp (Local): $(date)"
echo "└───────────────────────────────────────"
echo ""

# Output the reporters IP address
echo "┌───────────────────────────────────────"
echo "├─────── IP Information "
echo "" 
curl -s https://ipinfo.io/
echo ""
echo "└───────────────────────────────────────"
echo ""

# Test reachability to Vercel CNAME records
for i in "${ip_range[@]}"
do 
  echo "┌───────────────────────────────────────"
  echo "├─────── Testing $i "
  echo "Checking headers via $i"  
  # Get the headers of the site, bypassing DNS resolution and querying domain via IP directly
  curl -svko /dev/null https://${domain} --connect-to ::${i} --max-time 3 --stderr -
  # Ping the IP
  echo ""
  echo "Checking ping to $i" 
  ping -c 4 $i
  # Skip traceroute if ping succeeds
  if [ $? -ne 0 ]
  then
    echo ""
    echo "Checking tracert to $i" 
    traceroute -w 1 -m 30 -I $i
  fi
  echo "└───────────────────────────────────────"
  echo ""
done

# Resolve affected domain
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} "
echo "" 
dig ${domain}
echo "└───────────────────────────────────────"
echo ""

# Resolve affected domain via public DNS
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} via 8.8.8.8"
echo "" 
dig ${domain} @8.8.8.8
echo "└───────────────────────────────────────"
echo ""

# Resolve affected domain directly
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} via trace"
echo "" 
dig ${domain} +trace
echo "└───────────────────────────────────────"
echo ""

# Output content of affected domain
echo "┌───────────────────────────────────────"
echo "├─────── Output of ${domain}"
echo "" 
curl -svk https://${domain} --stderr -
echo ""
echo "└───────────────────────────────────────"
echo ""

# Calculate duration
end=$(date +%s)
duration=$((end-start))

echo ""

echo "┌───────────────────────────────────────"
echo "│ Time elapsed: ${duration} seconds"
echo "│" 
echo "├─────── FINISHED"
echo "└───────────────────────────────────────"
echo ""
echo ""
echo ""
echo "File can be found at $(pwd)/vercel-debug.txt"
echo ""
