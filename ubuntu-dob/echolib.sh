#!/bin/bash

red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
NC="\033[0m" # No Color

function redEcho() {
  echo -e "${red}$1${NC}"
}

function greenEcho() {
  echo -e "${green}$1${NC}"
}

function yellowEcho() {
  echo -e "${yellow}$1${NC}"
}

function blueEcho() {
  echo -e "${blue}$1${NC}"
}
