# Run these commands from the affected/problematic network
# Once completed, send the file to Vercel support

#IP ranges
$default_range="76.76.21.9","76.76.21.22","76.76.21.61","76.76.21.93","76.76.21.98","76.76.21.123","76.76.21.142","76.76.21.164","76.76.21.241"
$hobby_range="216.198.79.1","216.198.79.65","216.198.79.129","216.198.79.193","64.29.17.1","64.29.17.65","64.29.17.129","64.29.17.193"

# Ask for domain and don't accept no domain
# Also, we need to ensure not to pass an URL (https://example.com/path) 
# rather than only the domain name
$domain = $null
while ((!$domain) -or ($domain -Match "`/")) {
    $domain = Read-Host "Domain to test (e.g. example.com): "
}

# Select relevant IP range
if ($domain -match '.vercel.app$') {
  $ip_range=$hobby_range 
} else {
  $ip_range=$default_range
}

# Measure time 
$start = get-date

echo "+---------------------------------------"
echo "+------- STARTING"
echo "|" 
# Show affected domain
echo "| Domain to test: ${domain} "
# Capture time/date
echo "| Timestamp (UTC): $((get-date).ToUniversalTime())"
echo "| Timestamp (Local): $(get-date)"
echo "+---------------------------------------"
echo ""

# Output the reporters IP address
echo "+---------------------------------------"
echo "+------- IP Information "
echo "" 
curl.exe -s https://ipinfo.io/
echo ""
echo "+---------------------------------------"
echo ""

# Test reachability to Vercel A record
echo "+---------------------------------------"
echo "+------- Testing 76.76.21.21 "
echo "" 
ping -n 4 76.76.21.21
echo "" 
tracert -w 1 -h 30 76.76.21.21
echo "+---------------------------------------"
echo ""

# Test reachability to Vercel CNAME records
ForEach ($i in $ip_range) {
  echo "+---------------------------------------"
  echo "+------- Testing $i "
  echo "" 
  ping -n 4 $i
  # Skip traceroute if ping succeeds
  if ($? -eq $false) {
   echo "" 
    tracert -w 1 -h 30 $i
  }
  echo "+---------------------------------------"
  echo ""
}

# Resolve affected domain
echo "+---------------------------------------"
echo "+------- nslookup debug ${domain} "
echo "" 
nslookup -debug ${domain}
echo "+---------------------------------------"
echo ""

# Resolve affected domain via public DNS
echo "+---------------------------------------"
echo "+------- nslookup ${domain} via 8.8.8.8"
echo "" 
nslookup ${domain} 8.8.8.8
echo "+---------------------------------------"
echo ""

# Output content of affected domain
echo "+---------------------------------------"
echo "+------- Output of ${domain}"
echo "" 
curl.exe -svk https://${domain} --stderr -
echo ""
echo "+---------------------------------------"
echo ""

# Output pathping. Not needed at present.
# ForEach ($i in "76.76.21.21","76.76.21.9","76.76.21.22","76.76.21.61","76.76.21.93","76.76.21.98","76.76.21.123","76.76.21.142","76.76.21.164","76.76.21.241") { echo "Testing $i"; pathping -h 30 $i}

# Calculate duration
$end = get-date
$duration = ($end-$start)

echo ""

echo "+---------------------------------------"
echo "| Time elapsed: $duration seconds"
echo "|" 
echo "+------- FINISHED"
echo "+---------------------------------------"
echo ""
echo ""
echo ""
echo "File can be found at $(pwd)\vercel-debug.txt"
echo ""
