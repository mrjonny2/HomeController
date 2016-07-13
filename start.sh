
systemctl daemon-reload
systemctl start unifi
systemctl stop unifi

sudo chown -R unifi:unifi /var/lib/unifi /var/log/unifi /var/run/unifi /usr/lib/unifi/work

systemctl daemon-reload
systemctl start unifi

nohup socat tcp-listen:80,fork tcp:localhost:8443 > socat.log 2>&1 &

rm /datadb/mongod.lock
/usr/bin/mongod --dbpath /datadb --repair
/usr/bin/mongod --dbpath /datadb --fork --logpath mongod.log && node index.js