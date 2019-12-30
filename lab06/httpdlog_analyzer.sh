# defenition variables:
# path to log file
logFile=./access.log
# lockfile
lockfile=/tmp/httpdlog.pid
# number of TOP active IPs
X=10
# number of TOP requested locations
Y=10
# email address for the report
email=admin

# create a pidfile
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then 
    # enable trap
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
    # print header
    echo NGINIX hourly usage report > report.txt
    echo -------------------------- >> report.txt
    if [ -f last.tmp ]
    # if file last.tmp exists it means that the script have run before
    # the file contais date from last line on previous run
    then
        # get the time of last record from previous run
        start_time=$(cat last.tmp)
        # get the number of start record for the report
        start_line=$(cat access.log | grep -n -m 1 $start_time | awk -F":" '{print $1}')
        if [ -z "$start_line" ]
        # if the start_line is empty it means that log has been rotated after last run
        then
            echo "WARNING: it looks like log has been rotated" >> report.txt
            start_line=0
        fi
    # the file last.tmp doesn't exist
    else
        echo .. this is first run >> report.txt
        start_line=0
        start_time=$(head -n 1 access.log | awk '{print $4}' | sed 's/\[//')
    fi

    # get offset for tail
    number_of_strings=$(cat access.log | wc -l)
    begin_line=$(( number_of_strings - start_line))

    # Get latest record in log file and save it 
    end_time=$(tail -n 1 access.log | awk '{print $4}' | sed 's/\[//')
    echo $end_time > last.tmp

    echo .. begin from $start_line line of $number_of_strings lines >> report.txt
    echo .. from $start_time to $end_time >> report.txt
    echo "-> TOP $X active IPs:" >> report.txt
    tail -n $begin_line $logFile | awk '/GET/{ iprequests[$1]++ } END { for (i in iprequests) { printf "%4d - %13s\n", iprequests[i], i } }' | sort -rn | head -$X >> report.txt
    echo "-> TOP $X requested locations:" >> report.txt
    tail -n $begin_line $logFile | awk '/GET/{ locations[$7]++ } END { for (i in locations) { printf "%4d - %s\n", locations[i], i } }' | sort -rn | head -$X >> report.txt
    echo "-> Error codes:" >> report.txt
    tail -n $begin_line $logFile | awk 'BEGIN{FS="\""}{print $3}' | awk 'BEGIN{FIELDWIDTHS="1 3"}{if ($1 < 600 && $1 > 399) print $1}' | sort -u | sort >> report.txt
    echo "-> All HTTP codes:" >> report.txt
    tail -n $begin_line $logFile | awk 'BEGIN{FS="\""}{print $3}' | awk 'BEGIN{FIELDWIDTHS="1 3"}{ codes[$1]++ } END { for (i in codes) { printf "%4d - %3d\n", codes[i], i } }' | sort -rn >> report.txt
    # print footer
    echo -------------------------- >> report.txt

    # send report to the email
    cat report.txt | mail -s "NGINX Report: from $start_time to $end_time" $email

    # remove pidfile
    rm -f "$lockfile"
    
    # disable trap
    trap - INT TERM EXIT
else
    echo "Failed to acquire lockfile: $lockfile."
    echo "Held by $(cat $lockfile)"
fi