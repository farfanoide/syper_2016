#!/usr/bin/env bash

if ! command -v _success &> /dev/null;then
    source test_helpers.sh
fi

SOCKETS_DIR=$(ps aux | grep -oP "/tmp/pycore.[0-99999999999].+?(?=/)" | head -n1)

function node_ping()
{
  local node=$1 host=$2
  vcmd -c "${SOCKETS_DIR}/${node}" -- ping $host -c 1 -W 1 &> /dev/null
}

function _node_can_ping_port()
{
  local node=$1 ip=$2 port=$3
  vcmd -c "${SOCKETS_DIR}/${node}" -- nc -w 1 $ip $port < /dev/null
}

# INTERNAL HOSTS {{{ #

SUCURSAL_NODES="User6 User5 ImpresoraSucursal"
SUCURSAL_NODES_IPS="193.81.6.11 193.81.6.23 193.81.6.20"

CENTRAL_NODES="User1 User2 SMTP-syper-edu"
CENTRAL_NODES_IPS="193.81.7.14 193.81.7.35 193.81.7.20"

EXTERNAL_NODES="b-root-server c-root-server d-root-server"

_info 'Testeando acceso a internet desde la sucursal'
for node in $SUCURSAL_NODES ; do
  if node_ping $node 'google.com'; then
    _success "[SUCCESS] ${node} Tiene acceso a internet"
  else
    _error "[ERROR] ${node} no tiene acceso a internet"
  fi
done

_info 'Testeando acceso a internet desde la central'
for node in $CENTRAL_NODES ; do
  if node_ping $node 'google.com'; then
    _success "[SUCCESS] ${node} Tiene acceso a internet"
  else
    _error "[ERROR] ${node} no tiene acceso a internet"
  fi
done

_info 'Testeando acceso a la central desde la sucursal'
for central_node_ip in $CENTRAL_NODES_IPS ; do
  for sucursal_node in $SUCURSAL_NODES ; do
    if node_ping $sucursal_node $central_node_ip; then
      _success "[SUCCESS] ${sucursal_node} Tiene acceso a ${central_node_ip}" 
    else
      _error "[ERROR] ${sucursal_node} no tiene acceso a ${central_node_ip}"
    fi
  done
done


# }}} INTERNAL HOSTS #

# EXTERNAL HOSTS {{{ #

_info 'Testeando acceso hosts de la Central desde Internet'
for central_node_ip in $CENTRAL_NODES_IPS ; do
  for external_node in $EXTERNAL_NODES ; do
    if node_ping $external_node $central_node_ip; then
      _error "[ERROR] ${external_node} tiene acceso a ${central_node_ip}"
    else
      _success "[SUCCESS] ${external_node} no tiene acceso a ${central_node_ip}" 
    fi
  done
done

_info 'Testeando acceso hosts de la sucursal desde Internet'
for sucursal_node_ip in $SUCURSAL_NODES_IPS ; do
  for external_node in $EXTERNAL_NODES ; do
    if node_ping $external_node $sucursal_node_ip; then
      _error "[ERROR] ${external_node} tiene acceso a ${sucursal_node_ip}"
    else
      _success "[SUCCESS] ${external_node} no tiene acceso a ${sucursal_node_ip}" 
    fi
  done
done


ns_syper_edu_ip=193.81.7.34
www_syper_edu_ip=193.81.7.36
smtp_syper_edu_ip=193.81.7.35

_info 'Testeando acceso a servicios publicos de la central desde Internet'
for external_node in $EXTERNAL_NODES ; do

  if _node_can_ping_port $external_node $ns_syper_edu_ip 53; then
    _success "[SUCCESS] ${external_node} tiene acceso a DNS en ${ns_syper_edu_ip}" 
  else
    _error "[ERROR] ${external_node} no tiene acceso a DNS en ${ns_syper_edu_ip}" 
  fi

  if _node_can_ping_port $external_node $www_syper_edu_ip 80; then
    _success "[SUCCESS] ${external_node} tiene acceso a WEB en ${www_syper_edu_ip}" 
  else
    _error "[ERROR] ${external_node} no tiene acceso a WEB en ${www_syper_edu_ip}" 
  fi

  if _node_can_ping_port $external_node $smtp_syper_edu_ip 25; then
    _success "[SUCCESS] ${external_node} tiene acceso a SMTP en ${smtp_syper_edu_ip}" 
  else
    _error "[ERROR] ${external_node} no tiene acceso a SMTP en ${smtp_syper_edu_ip}" 
  fi

done

# }}} EXTERNAL HOSTS #
