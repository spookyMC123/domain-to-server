#!/bin/bash

#========= CONFIG SECTION =========#
LOCAL_PORT=3000

# Replace this after first tunnel test
CLOUDFLARE_TUNNEL_URL="your-tunnel.trycloudflare.com"
#==================================#

echo ""
echo "🌐 Cloudflare Tunnel Auto Setup Script"
echo "📍 Local App: http://localhost:$LOCAL_PORT"
echo ""

# Step 1: Download and install cloudflared
echo "🔧 Installing cloudflared..."
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

# Step 2: Test tunnel once
echo "🚀 Testing Tunnel (temporary)..."
cloudflared tunnel --url http://localhost:$LOCAL_PORT &
sleep 5

echo "⚠️ Copy the URL above (https://xxxxx.trycloudflare.com)"
echo "🔁 Update this script variable: CLOUDFLARE_TUNNEL_URL"
echo "⏳ Waiting for you to press ENTER after updating script..."
read -p "👉 Press ENTER when done..."

# Step 3: Create systemd service
echo "🛠️ Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/cloudflared.service" <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel --url http://localhost:$LOCAL_PORT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step 4: Start service
echo "🔁 Reloading and starting tunnel service..."
sudo systemctl daemon-reexec
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# Step 5: Final DNS Instructions
echo ""
echo "✅ DONE!"
echo "👉 Now go to your domain's Cloudflare DNS and add a CNAME:"
echo ""
echo "    Type: CNAME"
echo "    Name: @"
echo "    Target: $CLOUDFLARE_TUNNEL_URL"
echo ""
echo "🌐 Your public app: https://yourdomain.eu.org"
echo ""
