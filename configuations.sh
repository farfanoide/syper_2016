#!/usr/bin/env bash
# vim:set et sw=2 ts=2 foldmethod=marker:

# GENERAL SETUP: {{{

SOCKETS_DIR=$(ps aux | grep -oP "/tmp/pycore.[0-99999999999].+?(?=/)" | head -n1)
CONFIGS_DIR=configs

_core_running()
{
  [ -n "${SOCKETS_DIR}" ]
}

if ! _core_running; then
  echo "Levanta la topologia chamigo"; exit 1
fi

# END GENERAL SETUP}}}

# DNS: {{{
function stop_dns()
{
  local node="$1"
  vcmd -c "${SOCKETS_DIR}/${node}" -- service bind9 stop
}

function start_dns()
{
  local node="$1"
  vcmd -c "${SOCKETS_DIR}/${node}" -- service bind9 start
}

function configure_dns()
{
  echo
  echo "Configuraciones DNS"
  echo "-------------------"

  echo "Configurando dns en User6" && \
    stop_dns 'User6'

  echo "Configurando dns en resolverDNS" && \
    stop_dns 'resolverDNS' && \
    cp "${CONFIGS_DIR}/dns/resolverDNS/named.conf" "${SOCKETS_DIR}/resolverDNS.conf/etc.bind" && \
    start_dns 'resolverDNS'

  echo "Configurando dns en ns-syper-edu" && \
    stop_dns 'ns-syper-edu' && \
    cp "${CONFIGS_DIR}/dns/servidorZona/named.conf" "${SOCKETS_DIR}/ns-syper-edu.conf/etc.bind" && \
    start_dns 'ns-syper-edu'
}
# END DNS }}}


# RUN STUFF: {{{
clear
./tests/test_dns.sh
# configure_dns
# ./tests/test_dns.sh
# END RUN STUFF: }}}
