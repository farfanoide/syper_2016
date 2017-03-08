#!/usr/bin/env bash


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
  ping -W 1 -c 1 193.81.5.10 &> /dev/null
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

_topologia_levantada || _info 'Esperamos hasta que la topologia responda'
while ! _topologia_levantada ; do
  sleep 1
done

# END GENERAL SETUP}}}

./tests/test_dns.sh
./tests/test_firewall.sh
# ./tests/test_vpn.sh
