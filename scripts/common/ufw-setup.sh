echo "Setting up firewall"
sudo ufw allow 8080/tcp comment 'accept 8080'
sudo ufw allow 80/tcp comment 'accept Apache'
sudo ufw allow 443/tcp comment 'accept HTTPS connections'
sudo ufw allow ssh comment 'accept SSH'
yes y | sudo ufw enable >/dev/null
