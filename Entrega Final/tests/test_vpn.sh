#!/usr/bin/env bash

if ! command -v _success &> /dev/null;then
    source test_helpers.sh
fi

SOCKETS_DIR=$(ps aux | grep -oP "/tmp/pycore.[0-99999999999].+?(?=/)" | head -n1)

function check_ping()
{
   vcmd -c $SOCKETS_DIR/n40 -- tcpdump -c 10  -i eth0 -nn -w  /tmp/test_vpn.pcap &> /dev/null

   if  tcpdump -r  /tmp/testVPN.pcap 2> /dev/null | grep "echo"; then
        _error "[ERROR] El transito entre sucursal y central no esta encriptado"
  else
        _success "[SUCCESS] El transito entre sucursal y central esta encriptado"
   fi

}

_info "Testeando enctriptado de trafico entre sucursal y central $(_error '(configurado desde topologia)')"
check_ping &
vcmd -c $SOCKETS_DIR/User6 -- ping www.syper.edu -c 10 > /dev/null

