[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory={$SERVER_PATH}/mtproxy
ExecStart={$SERVER_PATH}/mtproxy/mtg/mtg run {$SERVER_PATH}/mtproxy/mt.toml
Restart=on-failure

[Install]
WantedBy=multi-user.target