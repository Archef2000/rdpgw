config_file_path="/opt/rdpgw/rdpgw.yaml"
#PAA_SIG = 
#PAA_ENC = 
#SES_KEY = 
#SES_ENC = 
#OIDC_URL="http://keycloak:8080/auth/realms/rdpgw"
#OIDC_ID="rdpgw"
#OIDC_SEC="01cd304c-6f43-4480-9479-618eb6fd578f"
#ROUND_ROBIN=false
#LISTEN_PORT=9443
#GW_ADD=localhost:9443
#AUTH=OIDC
#ALLOWED_HOSTS=xrdp:3389

ROUND_ROBIN=$(echo "${ROUND_ROBIN}" | tr A-Z a-z)
if [ "${ROUND_ROBIN}" != "true" ]
then
    ROUND_ROBIN="false"
else
    ROUND_ROBIN="true"
fi


LISTEN_PORT=$(echo "${LISTEN_PORT}" | tr -dc '0-9')
if [ -z "${LISTEN_PORT}" ] ; then 
    LISTEN_PORT=9443
fi

check_keys () {
    if [ ${#PAA_SIG} -ne 32 ] ; then 
        PAA_SIG=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 32 )
        echo "::: generated PAATokenSigningKey as PAA_SIG=${PAA_SIG}"
    fi
    
    if [ ${#PAA_ENC} -ne 32 ] ; then 
        PAA_ENC=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 32 )
        echo "::: generated PAATokenEncryptionKey as PAA_ENC=${PAA_ENC}"
    fi

    if [ ${#SES_KEY} -ne 32 ] ; then 
        SES_KEY=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 32 )
        echo "::: generated SessionKey as SES_KEY=${SES_KEY}"
    fi
    
    if [ ${#SES_ENC} -ne 32 ] ; then 
        SES_ENC=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 32 )
        echo "::: generated SessionEncryptionKey as SES_ENC=${SES_ENC}"
    fi
}

check_keys

cat > "${config_file_path}" <<-EOF
Client:
 UsernameTemplate: "{{ username }}"
 NetworkAutoDetect: 0
 BandwidthAutoDetect: 1
 ConnectionType: 6
Security:
  PAATokenSigningKey: ${PAA_SIG}
  PAATokenEncryptionKey: ${PAA_ENC}
Server:
 CertFile: /opt/rdpgw/server.pem
 KeyFile: /opt/rdpgw/key.pem
 GatewayAddress: ${GW_ADD}
 Port: ${LISTEN_PORT}
 RoundRobin: §{ROUND_ROBIN}
 SessionKey: ${SES_KEY}
 SessionEncryptionKey: ${SES_ENC}
EOF

gen_hosts () {
    ALLOWED_HOSTS=$(echo "${ALLOWED_HOSTS}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
    if [ ! -z "${ALLOWED_HOSTS}" ]; then
    	echo " Hosts:" >> "${config_file_path}"
    	sec="\n  - "
    	output=$(echo "  - $ALLOWED_HOSTS" | sed 's/,/\n  - /g' )
    	echo "$output" >> "${config_file_path}"
    else
    	echo "::: ALLOWED_HOSTS not defined"
    fi
}

gen_hosts

check_auth () {
    if [ "${AUTH}" = "LOCAL" ]; then
        cat >> "${config_file_path}" <<-EOF
 AuthSocket: /tmp/rdpgw-auth.sock
 Authentication: 
  - local
Caps:
 TokenAuth: false
EOF
    exec /opt/rdpgw/rdpgw-auth &
    else
        cat >> "${config_file_path}" <<-EOF
 Authentication:
  - openid
Caps:
 TokenAuth: true
OpenId:
 ProviderUrl: ${OIDC_URL}
 ClientId: ${OIDC_ID}
 ClientSecret: ${OIDC_SEC}
EOF
    fi
}

check_auth
exec /opt/rdpgw/rdpgw
