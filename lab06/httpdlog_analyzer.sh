logFile=./access.log
X=10
Y=10

#get_http_code {
#}

echo "TOP $X active IPs:"
cat $logFile | awk '/GET/{ iprequests[$1]++ } END { for (i in iprequests) { printf "%4d - IP:%13s\n", iprequests[i], i } }' | sort -rn | head -$X
echo "TOP $X requested locations:"
cat $logFile | awk '/GET/{ locations[$7]++ } END { for (i in locations) { printf "%4d - location:%s\n", locations[i], i } }' | sort -rn | head -$X
echo "Error codes:"
cat $logFile | awk 'BEGIN{FS="\""}{print $3}' | awk 'BEGIN{FIELDWIDTHS="1 3"}{if ($1 < 600 && $1 > 399) print $1}' | sort -u | sort
echo "All HTTP codes:"
cat $logFile | awk 'BEGIN{FS="\""}{print $3}' | awk 'BEGIN{FIELDWIDTHS="1 3"}{ codes[$1]++ } END { for (i in codes) { printf "%4d - %3d\n", codes[i], i } }' | sort -rn

#cat http-status-codes.csv | awk '/^[[:digit:]]+,/BEGIN{FS=","}{print $1,$2}'
#awk '/^[[:digit:]]+,/BEGIN{FS=","}{print $1,$2}' http-status-codes.csv
