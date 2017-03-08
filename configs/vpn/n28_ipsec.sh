#!/bin/sh

# -------- CUSTOMIZATION REQUIRED --------
keydir=/etc/core/keys
certname=ipsec1
tunnelhosts="193.81.11.1AND193.81.17.1"
T1="193.81.7.0/28AND193.81.6.0/24 193.81.7.16/28AND193.81.6.0/24 193.81.7.32/28AND193.81.6.0/24"
# -------- END CUSTOMIZATION --------

echo "building config $PWD/ipsec.conf..." 
echo "building config $PWD/ipsec.conf..." > $PWD/ipsec.log

checkip=0
if [ "$(dpkg -l | grep " sipcalc ")" = "" ]; then
   echo "WARNING: ip validation disabled because package sipcalc not installed
        " >> $PWD/ipsec.log
   checkip=1
fi

echo "#!/usr/sbin/setkey -f
    # Flush the SAD and SPD
    flush;
    spdflush;

    # Security policies  \
     " > $PWD/ipsec.conf
i=0
for hostpair in $tunnelhosts; do 
    i=`expr $i + 1`
    # parse tunnel host IP
    thishost=${hostpair%%AND*}
    peerhost=${hostpair##*AND} 
    if [ $checkip = "0" ] &&
       [ "$(sipcalc "$thishost" "$peerhost" | grep ERR)" != "" ]; then
	  echo "ERROR: invalid host address $thishost or $peerhost \
             " >> $PWD/ipsec.log
    fi
    # parse each tunnel addresses 
    tunnel_list_var_name=T$i
    eval tunnels="$"$tunnel_list_var_name""
    for ttunnel in $tunnels; do
        lclnet=${ttunnel%%AND*}
        rmtnet=${ttunnel##*AND} 
    	if [ $checkip = "0" ] && 
           [ "$(sipcalc "$lclnet" "$rmtnet"| grep ERR)" != "" ]; then
    	    echo "ERROR: invalid tunnel address $lclnet and $rmtnet \
                 " >> $PWD/ipsec.log
	fi
    	# add tunnel policies
	echo "
    spdadd $lclnet $rmtnet any -P out ipsec
	esp/tunnel/$thishost-$peerhost/require;
    spdadd $rmtnet $lclnet any -P in ipsec
	esp/tunnel/$peerhost-$thishost/require; \
    	    " >> $PWD/ipsec.conf
    done
done

echo "building config $PWD/racoon.conf..."
if [ ! -e $keydir\/$certname.key ] || [ ! -e $keydir\/$certname.pem ]; then
     echo "ERROR: missing certification files under $keydir \
$certname.key or $certname.pem " >> $PWD/ipsec.log
fi
echo "
	 path certificate \"$keydir\";
	 listen {
		 adminsock disabled;
	 }
	 remote anonymous
	 {
		 exchange_mode main;
 		 certificate_type x509 \"$certname.pem\" \"$certname.key\";
		 ca_type x509 \"ca-cert.pem\";
		 my_identifier asn1dn;
		 peers_identifier asn1dn;

		 proposal {
			 encryption_algorithm 3des ;
			 hash_algorithm sha1;
			 authentication_method rsasig ;
			 dh_group modp768;
		 }
	 }
	 sainfo anonymous
	 {
		 pfs_group modp768;
		 lifetime time 1 hour ;
		 encryption_algorithm 3des, blowfish 448, rijndael ;
		 authentication_algorithm hmac_sha1, hmac_md5 ;
		 compression_algorithm deflate ;
	 }
	" > $PWD/racoon.conf

# the setkey program is required from the ipsec-tools package
echo "running setkey -f $PWD/ipsec.conf..."
setkey -f $PWD/ipsec.conf

echo "running racoon -d -f $PWD/racoon.conf..."
racoon -d -f $PWD/racoon.conf -l racoon.log


