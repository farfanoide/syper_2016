#!/usr/bin/env bash

if ! command -v _success &> /dev/null;then
  source test_helpers.sh
fi


_info 'Testeando IDS en N28 (might take a while...)'

vcmd -c $SOCKETS_DIR/User3 -- nmap -sV -p53 google.com &> /dev/null

if vcmd -c $SOCKETS_DIR/n28 -- ls var.log/snort/ | grep -q '193.81.7.22'; then
  _success "[SUCCESS] Se ha detectado requerimientos sospechosos en la red"
else
  _error "[ERROR] No se ha detectado requerimientos sospechosos en la red"
fi

_info 'Testeando IDS en N18 (might take a while...)'

vcmd -c $SOCKETS_DIR/User6 -- nmap -sV -p53 google.com &> /dev/null

if vcmd -c $SOCKETS_DIR/n18 -- ls var.log/snort/ | grep -q '193.81.6.21'; then
  _success "[SUCCESS] Se ha detectado requerimientos sospechosos en la red"
else
  _error "[ERROR] No se ha detectado requerimientos sospechosos en la red"
fi
