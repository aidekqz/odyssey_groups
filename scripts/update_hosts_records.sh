#!/bin/bash
CONTAINER="openldap"
FQDN="ldap.example.local"

IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER" 2>/dev/null)

if [ -z "$IP" ]; then
    echo "container $CONTAINER not founded"
    exit 1
fi

# remove old rec
sudo sed -i "/$FQDN/d" /etc/hosts
echo "$IP $FQDN" | sudo tee -a /etc/hosts
echo "add record $IP $FQDN"