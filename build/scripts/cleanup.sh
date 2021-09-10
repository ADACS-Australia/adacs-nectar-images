#!/bin/bash

# Clean up leftover build files
rm -fr /home/*/{.ssh,.ansible,.cache}
rm -fr /root/{.ssh,.ansible,.cache}
rm -fr /root/'~'*

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

# Clean up Ubuntu user (but don't remove home directory)
possible_users="ubuntu ec2-user"
for item in $possible_users; do
  userdel -f $item || true
done

# Writes zeroes to empty space on the volume;
# (allows for better compression)
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# synchronize corresponding file data in volatile memory and permanent storage;
# (forces immediate execution of pending reads and writes)
sync
