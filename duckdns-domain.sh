#!/bin/bash

# USER CONFIGURATION - EDIT THESE
DOMAIN="your-subdomain"
TOKEN="your-duckdns-token"
LOCAL_PORT=3000

echo "Updating DuckDNS..."
curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip="

echo "Installing nginx..."
sudo apt update
sudo apt install nginx -y

echo "Configuring nginx for $DOMAIN..."

NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN.duckdns.org;

    location / {
        proxy_pass http://localhost:$LOCAL_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/

echo "Testing nginx config..."
sudo nginx -t

echo "Reloading nginx..."
sudo systemctl reload nginx

echo "Setup complete! Your app should be accessible at: http://$DOMAIN.duckdns.org"

