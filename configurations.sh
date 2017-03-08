#!/usr/bin/env bash
# vim:set et sw=2 ts=2 foldmethod=marker:

# HELPERS: {{{
#===  COLORS AND CHARACTERS ====================================================
export R=$(tput setaf 1)
export G=$(tput setaf 2)
export Y=$(tput setaf 3)
export B=$(tput setaf 4)
export TAB='  '
export RESET=$(tput sgr0)

function _error()
{
  local message="$*"
  echo -e "${R}${message}${RESET}"
}

function _success()
{
  local message="$*"
  echo -e "${G}${message}${RESET}"
}

function _info()
{
  local message="$*"
  echo -e "${B}${message}${RESET}"
}

function _abort()
{
  local message="$*"
  _error "${message}"; exit 1
}


for helper in "_info _success _error _abort"; do
  export -f $helper
done

function _topologia_levantada()
{
  vcmd -c "${SOCKETS_DIR}/User6" -- ping -W 1 -c 1 193.81.7.14 &> /dev/null
}

function _core_running()
{
  [ -n "${SOCKETS_DIR}" ]
}

# END HELPERS }}}

# GENERAL SETUP: {{{

SOCKETS_DIR=$(ps aux | grep -oP "/tmp/pycore.[0-99999999999].+?(?=/)" | head -n1)
CONFIGS_DIR=configs

if ! _core_running; then
  _abort 'Levanta la topologia primero por favor ;)'
fi

# _topologia_levantada || _info 'Esperamos hasta que la topologia responda'
# while ! _topologia_levantada ; do
#   sleep 1
# done

# END GENERAL SETUP}}}

# DNS: {{{
function _stop_dns()
{
  local node="$1"
  vcmd -c "${SOCKETS_DIR}/${node}" -- service bind9 stop
}

function _start_dns()
{
  local node="$1"
  vcmd -c "${SOCKETS_DIR}/${node}" -- service bind9 start
}

function configure_dns()
{
  _info '\nConfiguraciones DNS'
  _info '-------------------'

  _info 'Configurando dns en User6' && \
    _stop_dns 'User6'

  _info 'Configurando dns en resolverDNS' && \
    _stop_dns 'resolverDNS' && \
    cp "${CONFIGS_DIR}/dns/resolverDNS/named.conf" "${SOCKETS_DIR}/resolverDNS.conf/etc.bind/named.conf.options" && \
    _start_dns 'resolverDNS'

  _info 'Configurando dns en ns-syper-edu' && \
    _stop_dns 'ns-syper-edu' && \
    cp "${CONFIGS_DIR}/dns/servidorZona/named.conf" "${SOCKETS_DIR}/ns-syper-edu.conf/etc.bind/named.conf.options" && \
    _start_dns 'ns-syper-edu'
}
# END DNS }}}

# FIREWALLS: {{{

function configure_firewalls()
{
  _info 'Configurando iptables en el Router N28'
  vcmd -c $SOCKETS_DIR/n28 -- iptables -P FORWARD DROP
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -i eth0 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -s 193.81.6.0/24 -d 193.81.7.0/26 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -d 193.81.7.34 -p udp --dport 53 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -d 193.81.7.34 -p tcp --dport 53 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -d 193.81.7.36 -p tcp --dport 80 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -d 193.81.7.35 -p tcp -m multiport --dports 25,993 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n28 -- iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

  _info 'Configurando iptables en el Router N18'
  vcmd -c $SOCKETS_DIR/n18 -- iptables -P FORWARD DROP
  vcmd -c $SOCKETS_DIR/n18 -- iptables -A FORWARD -i eth0 -j ACCEPT
  vcmd -c $SOCKETS_DIR/n18 -- iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
  vcmd -c $SOCKETS_DIR/n18 -- iptables -A FORWARD -s 193.81.7.0/26 -d 193.81.6.0/24  -j ACCEPT
}
# END FIREWALLS: }}}

# VPN: {{{

function configure_vpn()
{
  apt-get -yqq install sipcalc

  _info 'Copiando certificados a /etc/core/keys' && \
    mkdir -p '/home/core/syper/keys' && \
    cp -fr "${CONFIGS_DIR}/vpn/keys/*" /etc/core/keys/

  _info 'Configurando ipsec en N28' && \
    cp "${CONFIGS_DIR}/vpn/n28_ipsec.sh" $SOCKETS_DIR/n28.conf/ipsec.sh && \
    vcmd -c $SOCKETS_DIR/n28 -- sh ipsec.sh

  _info 'Configurando ipsec en N18' && \
    cp "${CONFIGS_DIR}/vpn/n18_ipsec.sh" $SOCKETS_DIR/n18.conf/ipsec.sh && \
    vcmd -c $SOCKETS_DIR/n18 -- sh ipsec.sh
}

# END VPN: }}}

# RUN STUFF: {{{
clear
configure_dns
configure_firewalls
# configure_vpn
# END RUN STUFF: }}}
