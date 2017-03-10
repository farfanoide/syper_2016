#!/usr/bin/env bash

if ! command -v _success &> /dev/null;then
    source test_helpers.sh
fi

_info "Testeando Web Application Firewall en intranet.syper.edu"

if vcmd -c $SOCKETS_DIR/User5 -- curl --silent -LS "intranet.syper.edu/vulnerabilities/xss_r/?name=holaaa" | grep -iq "damn vulnerable web application";then
    _success "[SUCCESS] La pagina responde correctamente"
else
    _error "[ERROR] La pagina no responde correctamente"
fi

if vcmd -c $SOCKETS_DIR/User5 -- curl --silent -LS "intranet.syper.edu/vulnerabilities/xss_r/?name=<script>" | grep -iq "ataque detectado";then
    _success "[SUCCESS] Ataque detectado"
else
    _error "[ERROR] no se detecto el ataque"
fi

_info "Testeando Web Application Firewall en www.syper.edu"

if curl --silent -LS "http://www.syper.edu/?q=hola&module=search" | grep -iq "no articles found for the query";then
    _success "[SUCCESS] La pagina responde correctamente"
else
    _error "[ERROR] La pagina no responde correctamente"
fi

if curl --silent -LS "http://www.syper.edu/?q=<script>&module=search" | grep -iq "ataque detectado"; then
    _success "[SUCCESS] Ataque detectado"
else
    _error "[ERROR] no se detecto el ataque"
fi
