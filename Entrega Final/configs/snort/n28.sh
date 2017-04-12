#!/usr/bin/env bash

rm -r var.log/snort &> /dev/null
mkdir -p var.log/snort

NETS='[193.81.7.0/28,193.81.7.16/28,193.81.7.32/28,193.81.7.48/28]' 

snort -D \
  -S HOME_NET="!${NETS}" \
  -S EXTERNAL_NET="${NETS}" \
  -c /etc/snort/snort.conf \
  -i eth0 \
  -l var.log/snort \
  -K ascii
