logFile=./access.log
X=10
Y=10

echo "TOP $X active IPs:"
cat $logFile | awk '/GET/{ iprequests[$1]++ } END { for (i in iprequests) { printf "%4d - IP:%13s\n", iprequests[i], i } }' | sort -rn | head -$X
echo "TOP $X requested locations:"
cat $logFile | awk '/GET/{ locations[$7]++ } END { for (i in locations) { printf "%4d - location:%s\n", locations[i], i } }' | sort -rn | head -$X

cat $logFile | awk '{ print "date: " $4 ; if ( $9 ~ /[0-9]/ ) { print "code: " $9 } else { print "correct code: " $7 } }'