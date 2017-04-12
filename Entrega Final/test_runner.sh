#!/usr/bin/env bash

source tests/test_helpers.sh

./tests/test_dns.sh
./tests/test_firewall.sh
./tests/test_waf.sh
./tests/test_vpn.sh
./tests/test_ids.sh
