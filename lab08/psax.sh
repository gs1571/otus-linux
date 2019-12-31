# get cputime
cputime=$(head -n 1 /proc/stat | awk '{print $2}')
printf "%5s %-8s %-6s %4s %-20s\n" PID TTY STAT TIME COMMAND

# just for debug
# range=(1237 1310 1395 26981 26862)
# range=(1938 1951)

# follow the instruction https://stackoverflow.com/questions/16726779/how-do-i-get-the-total-cpu-usage-of-an-application-from-proc-pid-stat
# get HZ and uptime
hz=$(grep 'CONFIG_HZ=' /boot/config-$(uname -r) | sed 's/CONFIG_HZ=//')
uptime=$(cat /proc/uptime | awk '{ print $1 }' | awk -F. '{ print $1 }')

# just for debug
#for item in "${range[@]}"

for item in $(ls -v /proc)
do
    # choose decimal only
    if [[ $item =~ ^-?[0-9]+$ ]]
    then
        # check terminal
        if [ -e /proc/$item/fd/0 ]
        then
            # get tty
            tty=$(ls -l /proc/$item/fd/0 | awk '{print $11}')
            # if not tty replace to ?
            if [[ $tty =~ \/null ]] || [[ ! $tty =~ ^\/dev ]]
            then
                tty="?"
            # if tty remove /dev
            else
                tty=$(echo $tty | sed 's/\dev\///')
            fi
        # if not replace to ?
        else
            tty="?"
        fi
        # check stat file
        if [ -e /proc/$item/stat ]
        then
            # get status
            stat=$(cat /proc/$item/stat | awk '{print $3}')
            # follow the instruction https://stackoverflow.com/questions/16726779/how-do-i-get-the-total-cpu-usage-of-an-application-from-proc-pid-stat
            # get utime, stime, cutime, cstime, starttime
            utime=$(cat /proc/$item/stat | awk '{ print $14 }')
            stime=$(cat /proc/$item/stat | awk '{ print $15 }')
            cutime=$(cat /proc/$item/stat | awk '{ print $16 }')
            cstime=$(cat /proc/$item/stat | awk '{ print $17 }')
            starttime=$(cat /proc/$item/stat | awk '{ print $22 }')

            total_time=$[utime+stime+cutime+cstime]
            seconds=$[uptime-(starttime/hz)]
            cpu_usage=$[100*((total_time/hz)/seconds)]
        # if check file doesn't exist, zeroize varibales
        else
            stat="?"
            cpu_usage=0
        fi
        # check command
        if [ -e /proc/$item/cmdline ]
        then
            cmd=$(cat /proc/$item/cmdline)
        else
            cmd=""
        fi

        printf "%5d %-8s %-6s %1.2f %-20s\n" $item $tty $stat $cpu_usage "$cmd"
    fi
done

