#!/bin/bash

function task() {
  >&2 printf "${barrow} %s\n" "$*";
}

task "removing dev loops and images"
losetup -D;