#!/bin/sh -eux

# Whiteout root
count=$(df --sync -kP / | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count - 1))
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count status=progress || echo "dd exit code $? is suppressed"
rm /tmp/whitespace