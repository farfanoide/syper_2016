#!/usr/bin/env bash

function check_dns_config()
{
  local test_name=$1
  case $test_name in

    'iterative_user6')
      command_to_run="dig www.google.com @193.81.6.21 +time=1"
      function condition() { grep -q '^;; connection timed out';}
      fail="Responde consultas"
      success="No ${fail}" ;;

    'recursive')
      command_to_run="dig www.google.com @193.81.7.34"
      function condition() { grep '^;; flags:' | grep -vq ra ;}
      fail="Responde consultas recursivas realizadas desde Internet"
      success="No ${fail}" ;;

    'transfer')
      command_to_run="dig AXFR syper.edu @193.81.7.34"
      function condition() { grep -q 'Transfer failed' ;}
      success="No realiza transferencia de zonas hacia Internet"
      fail="Realiza transferencia de zonas hacia Internet" ;;

    'version')
      command_to_run="dig @193.81.7.34 version.bind chaos txt"
      function condition() { grep -q 'NO-TE-DIGO' ;}
      success="Oculta la version del Bind"
      fail="No ${success}" ;;

    'version_resolver')
      command_to_run="dig @193.81.7.14 version.bind txt chaos +time=1"
      function condition() { ! ( grep -q 'ANSWER SECTION' ) ;}
      success="Oculta la version del Bind"
      fail="No ${success}" ;;
  esac

  if vcmd -c $SOCKETS_DIR/b-root-server -- $command_to_run | condition ;then
    _success "${success}"
  else
    _error "${fail}"
  fi
}

SOCKETS_DIR=$(ps aux | grep -oP "/tmp/pycore.[0-99999999999].+?(?=/)" | head -n1)

_info 'Testeando User6 no corra servidor DNS'
check_dns_config 'iterative_user6'

_info 'Testeando version en resolverDNS'
check_dns_config 'version_resolver'

_info "Tests ns-syper-edu"
check_dns_config 'recursive'
check_dns_config 'transfer'
check_dns_config 'version'

