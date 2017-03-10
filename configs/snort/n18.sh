#!/usr/bin/env bash

rm -r var.log/snort &> /dev/null
mkdir -p var.log/snort

NETS='193.81.6.0/24'

snort -D \
  -S HOME_NET="!${NETS}" \
  -S EXTERNAL_NET="${NETS}" \
  -c /etc/snort/snort.conf \
  -i eth0 \
  -l var.log/snort \
  -K ascii
