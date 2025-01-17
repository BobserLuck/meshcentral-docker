  GNU nano 4.8                                                                                  startup.sh                                                                                            
#!/bin/bash

export NODE_ENV=production

export HOSTNAME
export REVERSE_PROXY
export REVERSE_PROXY_TLS_PORT
export IFRAME
export ALLOW_NEW_ACCOUNTS
export WEBRTC

if [ -f "meshcentral-data/config.json" ]
    then
        node node_modules/meshcentral 
    else
        cp config.json.template meshcentral-data/config.json
        sed -i "s/\"cert\": \"myserver.mydomain.com\"/\"cert\": \"$HOSTNAME\"/" meshcentral-data/config.json
        sed -i "s/\"NewAccounts\": true/\"NewAccounts\": \"$ALLOW_NEW_ACCOUNTS\"/" meshcentral-data/config.json
        sed -i "s/\"WebRTC\": false/\"WebRTC\": \"$WEBRTC\"/" meshcentral-data/config.json
        sed -i "s/\"AllowFraming\": false/\"AllowFraming\": \"$IFRAME\"/" meshcentral-data/config.json
        if [ -z "$SESSION_KEY" ]; then
        SESSION_KEY="$(cat /dev/urandom | tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_`{|}~' | fold -w 32 | head -n 1)"
        fi
        sed -i "s/\"_sessionKey\": \"MyReallySecretPassword1\"/\"sessionKey\": \"$SESSION_KEY\"/" meshcentral-data/config.json
        if [ "$REVERSE_PROXY" != "false" ]
            then 
                sed -i "s/\"_certUrl\": \"my\.reverse\.proxy\"/\"certUrl\": \"https:\/\/$REVERSE_PROXY:$REVERSE_PROXY_TLS_PORT\"/" meshcentral-data/config.json
                node node_modules/meshcentral
                exit
        fi
        node node_modules/meshcentral --cert "$HOSTNAME"     
fi
