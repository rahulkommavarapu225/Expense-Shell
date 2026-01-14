[Unit]
Description = Backend.Service

[Service]
User=expense
Environment=DB_HOST="mysql.practice25.online"
ExecStart=/bin/node/app/index.js
SyslogIdentifier=Backend

[Install]
Wanted By=Multi-User.target