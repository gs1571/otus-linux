#!/bin/bash

# download Guest tools
curl https://download.virtualbox.org/virtualbox/6.0.14/VBoxGuestAdditions_6.0.14.iso -o /tmp/VBoxGuestAdditions_6.0.14.iso
# mount Guest tools
mount /tmp/VBoxGuestAdditions_6.0.14.iso /mnt -o loop
# install Guest tools
/mnt/VBoxLinuxAdditions.run
