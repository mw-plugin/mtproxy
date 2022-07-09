[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory={$SERVER_PATH}/mtproxy
EnvironmentFile=-{$SERVER_PATH}/mtproxy/mt.env
ExecStart={$SERVER_PATH}/mtproxy/mtproto-proxy -u nobody -p 8888 -H $PORT -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1
Restart=on-failure

[Install]
WantedBy=multi-user.target