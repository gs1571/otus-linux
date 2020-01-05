# cheking that bc is installed
if ! which bc &> /dev/null
then
    echo "The script require bc (an arbitrary precision calculator language), please, install it before:"
    echo "  sudo yum install bc"
    echo "or"
    echo "  sudo apt install bc"
    exit 1
fi

convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d" $h $m $s
}

# get cputime
cputime=$(head -n 1 /proc/stat | awk '{print $2}')
printf "%5s %-8s %-6s%9s %-20s\n" PID TTY STAT TIME COMMAND

# just for debug
# range=(1237 1310 1395 26981 26862)
# range=(1938 1951)

# follow the instruction https://stackoverflow.com/questions/16726779/how-do-i-get-the-total-cpu-usage-of-an-application-from-proc-pid-stat
#hz=$(grep 'CONFIG_HZ=' /boot/config-$(uname -r) | sed 's/CONFIG_HZ=//')
clk_tck=$(getconf CLK_TCK)

# just for debug
#for item in "${range[@]}"

for item in $(ls -v /proc)
do
    # choose decimal only
    if [[ $item =~ ^-?[0-9]+$ ]]
    then
        # check terminal
        if [[ -e /proc/$item/fd/0 ]]
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
        if [[ -e /proc/$item/stat ]]
        then
            # get status
            stat=$(cat /proc/$item/stat | awk '{print $3}')
            # follow the instruction https://stackoverflow.com/questions/16726779/how-do-i-get-the-total-cpu-usage-of-an-application-from-proc-pid-stat
            # get utime, stime, starttime
            utime=$(cat /proc/$item/stat | awk '{ print $14 }')
            stime=$(cat /proc/$item/stat | awk '{ print $15 }')
            # line calculator - bc will be used
            proc_total_time=$( echo "$utime / $clk_tck + $stime / $clk_tck" | bc )

        # if check file doesn't exist, zeroize varibales
        else
            stat="?"
            cpu_usage=0
        fi
        # check command
        if [[ -e /proc/$item/cmdline ]]
        then
            cmd=$(cat /proc/$item/cmdline)
        fi
        if [[ -z $cmd ]] && [[ -e /proc/$item/comm ]]
        then
            comm=$(cat /proc/$item/comm)
            cmd=$(echo "[" $comm "]")
        fi  

        #printf "%5d %-8s %-6s %1.2f %-20s\n" $item $tty $stat $proc_total_time "$cmd"
        printf "%5d %-8s %-6s%9s %-20s\n" $item $tty $stat $(convertsecs $proc_total_time) "$cmd"

    fi
done

