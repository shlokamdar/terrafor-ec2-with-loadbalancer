
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
sleep 5
cat <<HTML > /usr/share/nginx/html/index.html
<h1>Hello from NGINX on Amazon Linux 2023!</h1>
HTML
EOF
