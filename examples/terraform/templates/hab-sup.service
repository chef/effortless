[Unit]
Description=Habitat Supervisor

[Service]
Environment=HAB_NOCOLORING=true
Environment=HAB_NONINTERACTIVE=true
ExecStartPre=/bin/bash -c /bin/systemctl
ExecStart=/bin/hab run ${flags}

[Install]
WantedBy=default.target
