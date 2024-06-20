#!/usr/bin/env bash

hostname=$(hostname)
date=$(date "+%Y%m%d")
os=$(uname -s)

echo "S.M.A.R.T. test - short - $hostname - $date"
echo

declare -a disklist

if [ $os = 'Linux' ]; then
  cmd='/usr/sbin/smartctl '
  diskprefix='sd'
  disklist=( a b c d e f g h i j k l m n o p q r s t u v w x y z )
elif [ $os = 'Darwin' ]; then
  if [ -r '/opt/homebrew/bin/smartctl' ]; then
    cmd='/opt/homebrew/bin/smartctl'
  elif [ -r '/usr/local/bin/smartctl' ]; then
    cmd='/usr/local/bin/smartctl '
  else
    echo 'smartctl not in path'
    exit 1
  fi
  diskprefix='disk'
  disklist=( 0 1 2 3 4 5 6 7 8 9 11 12 13 14 15 )
else
  echo 'Unrecognised Operating System.'
  exit 1
fi

for i in "${disklist[@]}"
do
  disk=/dev/${diskprefix}${i}
  if [ -e $disk ]; then
    $cmd --smart=on $disk > /dev/null
    $($cmd --info $disk | grep -q 'SMART support is: Available' )
    if [ $? -eq 0 ]; then
      echo $disk
      $cmd --smart=on   $disk > /dev/null
      $cmd --test=short $disk > /dev/null
      sleep 180
      $cmd --smart=on   $disk > /dev/null
      $cmd -l selftest  $disk | grep '# 1'
      echo
    fi
  fi
done

