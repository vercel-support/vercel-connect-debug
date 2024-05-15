#/bin/bash
# Run these commands from the affected/problematic network
# Once completed, send the file to Vercel support

# Ask for domain and don't accept no domain
domain=""
while [[ -z "$domain" ]]
do
  echo "Domain to test: "
  read domain </dev/tty
done

# Measure time 
start=`date +%s`

echo "┌───────────────────────────────────────"
echo "├─────── STARTING"
echo "│" 
# Show affected domain
echo "│ Domain to test: ${domain} "
# Capture time/date
echo "│ Timestamp: $(date)"
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

# Test reachability to Vercel A record
echo "┌───────────────────────────────────────"
echo "├─────── Testing 76.76.21.21 "
echo "" 
ping -c 4 76.76.21.21
echo "" 
traceroute -w 1 -m 30 -I 76.76.21.21
echo "└───────────────────────────────────────"
echo ""

# Test reachability to Vercel CNAME records
for i in "76.76.21.9" "76.76.21.22" "76.76.21.61" "76.76.21.93" "76.76.21.98" "76.76.21.123" "76.76.21.142" "76.76.21.164" "76.76.21.241"
do 
  echo "┌───────────────────────────────────────"
  echo "├─────── Testing $i "
  echo "" 
  ping -c 4 $i
  # Skip traceroute if ping succeeds
  if [ "$?" != 0 ]
  then
    echo "" 
    traceroute -w 1 -m 30 -I $i
  fi
  echo "└───────────────────────────────────────"
  echo ""
done

# Resolve affected domain
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} "
echo "" 
dig ${1}
echo "└───────────────────────────────────────"
echo ""

# Resolve affected domain via public DNS
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} via 8.8.8.8"
echo "" 
dig ${1} @8.8.8.8
echo "└───────────────────────────────────────"
echo ""

# Resolve affected domain directly
echo "┌───────────────────────────────────────"
echo "├─────── dig ${domain} via trace"
echo "" 
dig ${1} +trace
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

# Output mtr result. Commented out due to Sudo requirement
# for i in "76.76.21.21" "76.76.21.22" "76.76.21.9" "76.76.21.22" "76.76.21.61" "76.76.21.93" "76.76.21.98" "76.76.21.123" "76.76.21.142" "76.76.21.164" "76.76.21.241";do echo "Testing $i" && sudo mtr -wr -c 20 $i;done

# Calculate duration
end=`date +%s`
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
