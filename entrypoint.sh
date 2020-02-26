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

exec $JCUSTOMER_HOME/bin/karaf daemon
