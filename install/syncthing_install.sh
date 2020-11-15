#!/bin/bash

url='https://api.github.com/repos/syncthing/syncthing/releases/latest'
patch='/tmp'
servpatch='/etc/systemd/system/syncthing@.service'
a=$(ls  /tmp |grep 'syncthing-linux-amd64' |sed -n 1p )
b=$(ls  /tmp |grep 'syncthing-linux-amd64' |sed -n 1p | cut -c 1-29 )

curl -s $url | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4 | wget  -qi - -nc -P $patch



tar -zxvf "$patch/$a" -C '/tmp' > '/tmp/syncthing_install.log' 2>&1

 

cp "$patch/$b/syncthing"  '/usr/local/bin/'

cat << EOF > $servpatch

[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target

[Service]
User=%i
ExecStart=/usr/local/bin/syncthing -no-browser -gui-address="0.0.0.0:8384" -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

# Hardening
ProtectSystem=full
PrivateTmp=true
SystemCallArchitectures=native
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

systemctl start "syncthing@$USER"

#systemctl enable "syncthing@$USER"

ss -tunelp | grep 8384

echo ''
echo -e "\033[32m url htttp://ip:8384\033[0m"

#echo 'url htttp://ip:8384'
#ldconfig





