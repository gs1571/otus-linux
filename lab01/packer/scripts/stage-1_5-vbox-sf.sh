#!/bin/bash

# Install elrepo
curl https://download.virtualbox.org/virtualbox/6.0.14/VBoxGuestAdditions_6.0.14.iso -o /tmp/VBoxGuestAdditions_6.0.14.iso
mount /tmp/VBoxGuestAdditions_6.0.14.iso /mnt -o loop
/mnt/VBoxLinuxAdditions.run
