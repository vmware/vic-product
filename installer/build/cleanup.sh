#!/bin/bash

function task() {
  >&2 printf "${barrow} %s\n" "$*"
}

task "removing dev loops"
for LOOPS in $(losetup -a | awk -F':' {'print $1'} | awk -F'/' {'print $3'}); do
  for LOOPPART in $(ls /dev/${LOOPS}*| awk -F'/' {'print $4'}); do
    dmsetup remove ${LOOPPART};
  done;
  losetup -d /dev/${LOOPS};
done

task "removing build artifacts"
rm -rf ./build/baseimage/bin