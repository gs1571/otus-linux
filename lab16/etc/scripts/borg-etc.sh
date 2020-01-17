#!/bin/bash
# user and server
USER=borg
SERVER=server
# type fo backup, can be:
# - etc
# - system
# - data
TYPEOFBACKUP=etc
# repository url
REPOSITORY=$USER@$SERVER:storage/$(hostname)-$TYPEOFBACKUP
# password
export BORG_PASSPHRASE='1qaz@WSX'
#
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Before backup
# ...

# Backup
borg create                                 \
    --verbose                               \
    --filter AME                            \
    --list                                  \
    --stats                                 \
    --show-rc                               \
    --compression lz4                       \
    --exclude-caches                        \
    $REPOSITORY::'{now:%Y-%m-%d-%H-%M}'     \
    /etc                                    \

backup_exit=$?

info "Pruning repository"

borg prune                          \
    --list $REPOSITORY              \
    --show-rc                       \
    --keep-last     3               \
    --keep-hourly   24              \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}