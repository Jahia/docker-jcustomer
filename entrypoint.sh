#!/bin/bash

echo "
export KARAF_OPTS=\"-Dunomi.autoStart=true\"
##### CUSTOM ENV VARS #####" >> $JCUSTOMER_HOME/bin/setenv
# Set unomi env vars
env_vars=$(env)
echo "$env_vars" | while IFS= read -r env_var; do
    if [[ $env_var == unomi_env_var_* ]]; then
        # Remove prefix
        ev=${env_var#"unomi_env_var_"}
        echo "export $ev">> $JCUSTOMER_HOME/bin/setenv
    fi
done

if [ ! -z "$MAXMIND_KEY" ]; then
    wget -nv -O GeoLite2-City.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_KEY&suffix=tar.gz"
    tar xzvf GeoLite2-City.tar.gz
    cp GeoLite2-City_*/GeoLite2-City.mmdb $JCUSTOMER_HOME/etc
    rm -rf GeoLite2-City*
fi

if [[ $unomi_env_var_UNOMI_ELASTICSEARCH_SSL_ENABLE == 'true' ]]; then
    protocol="https"
else
    protocol="http"
fi
if [[ $unomi_env_var_UNOMI_ELASTICSEARCH_SSL_TRUST_ALL_CERTIFICATES == 'true' ]]; then
    optiontrust='-k'
fi
if [[ "$unomi_env_var_UNOMI_ELASTICSEARCH_USERNAME" != '' ]]; then
    credentials="-u $unomi_env_var_UNOMI_ELASTICSEARCH_USERNAME:$unomi_env_var_UNOMI_ELASTICSEARCH_PASSWORD"
fi
check_cmd="curl -m 5 -fsSL $optiontrust $credentials ${protocol}://${unomi_env_var_UNOMI_ELASTICSEARCH_ADDRESSES}/_cat/health?h=status"
check_es(){
    status=$($check_cmd)
    case "$status" in
        yellow|green) return 0;; 
        *) return 1;;
    esac
}

attempt=0
max_attempts=120

until check_es || [[ $attempt -eq $max_attempts ]]; do
    echo "Elastic Search is not yet available - Attempt $(( ++ attempt )) / $max_attempts - Status : $status - waiting..."
    sleep 1
done

exec $JCUSTOMER_HOME/bin/karaf daemon
