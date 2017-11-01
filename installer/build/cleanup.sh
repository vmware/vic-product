#!/bin/bash

function task() {
  >&2 printf "${barrow} %s\n" "$*";
}

task "removing dev loops and images"
for img in $(ls build/baseimage/*.img 2>/dev/null); do
  loop=$(losetup -l -O NAME -j $img | tail -n 1);
  rm $img;
  losetup -d $loop;
done

task "removing build artifacts";
rm -rf ./build/baseimage/bin;