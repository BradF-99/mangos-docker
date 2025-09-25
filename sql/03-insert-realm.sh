#!/bin/bash
PUBLIC_IP=$(curl ipinfo.io/ip)
echo "Public IP detected as $IP"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" classicrealmd <<EOF
DELETE FROM realmlist WHERE id=1;
INSERT INTO realmlist (id, name, address, port, icon, realmflags, timezone, allowedSecurityLevel)
VALUES ('1', 'CMaNGOS', '$PUBLIC_IP', '8085', '1', '0', '3', '0');
EOF