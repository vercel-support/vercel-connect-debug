# Run these commands from the affected/problematic network
# Once completed, send the file to Vercel support

# Ask for domain and don't accept no domain
# Also, we need to ensure not to pass an URL (https://example.com/path) 
# rather than only the domain name
$domain = $null
while ((!$domain) -or ($domain -Match "`/")) {
    $domain = Read-Host "Domain to test (e.g. example.com): "
}

# Lookup the DNS record to return the IP Ranges
echo "+---------------------------------------"
echo "+------- Fetching IP Addresses"
echo "|" 
# Make curl request to the IP Range Lookup API
$ip_addresses = curl.exe -s -X POST "https://ip-ranges.vercel.support" -d "${domain}"
# Check if API call failed, returned empty, or returned special error responses
# If any of these conditions are true, exit immediately without running tests
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($ip_addresses) -or $ip_addresses -eq "Not on Vercel" -or $ip_addresses -eq "DNS lookup failed") {
    echo "| Range lookup failed - $(if ([string]::IsNullOrEmpty($ip_addresses)) { 'No response from API' } else { $ip_addresses })"
    echo "+---------------------------------------"
    echo ""
    return
} else {
    echo "| ${domain} IP range: $ip_addresses"
    echo "+---------------------------------------"
    echo ""
    # Parse response and convert to array
    $ip_range = ($ip_addresses -split ',').Trim()
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

# Test reachability to Vercel CNAME records
ForEach ($i in $ip_range) {
  echo "+---------------------------------------"
  echo "+------- Testing $i "
  echo "Checking headers via $i" 
  # Get the headers of the site, bypassing DNS resolution and querying domain via IP directly
  curl.exe -svko NUL https://$domain --connect-to ::$i --max-time 3 --stderr -
  # Ping the IP
  echo ""
  echo "Checking ping to $i" 
  ping -n 4 $i
  # Skip traceroute if ping succeeds
  if ($LASTEXITCODE -ne 0) {
   echo ""
   echo "Checking tracert to $i" 
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

# Calculate duration
$end = get-date
$duration = ($end-$start)

echo ""

echo "+---------------------------------------"
echo "| Time elapsed: $([math]::Round($duration.TotalSeconds, 1)) seconds"
echo "|" 
echo "+------- FINISHED"
echo "+---------------------------------------"
echo ""
echo ""
echo ""
echo "File can be found at $(Get-Location)\vercel-debug.txt"
echo ""
