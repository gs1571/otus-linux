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

info "Initializing repository"

# init
borg init                           \
    --encryption repokey            \
    $REPOSITORY                     \

global_exit=$?

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
