#!/bin/bash
# Nikolay

filename=$1
IFS=$'\n'
for next in `cat $filename`
do
ret=$(echo Q | timeout 5 openssl s_client -connect ${next}:443 -ssl3 2> /dev/null)
if echo "${ret}" | grep -q 'Protocol.*SSLv3'; then
  if echo "${ret}" | grep -q 'Cipher.*0000'; then
    echo "SSL 3.0 disabled"
  else
    echo "$next: SSL 3.0 enabled"
fi
  else
  echo "$next: SSL disabled or other error"
fi
done
