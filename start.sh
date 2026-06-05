#!/bin/sh
set -e

echo "Starting startup script..."
echo "Current user: $(id)"

# Ensure the persistent directory exists
mkdir -p /var/lib/headscale
mkdir -p /var/run/headscale

# Seed the persistent volume if it's empty (database ONLY)
if [ ! -f /var/lib/headscale/db.sqlite ] && [ -f /tmp/headscale_data/db.sqlite ]; then
    echo "Seeding db.sqlite from repository..."
    cp /tmp/headscale_data/db.sqlite /var/lib/headscale/db.sqlite
fi

# Ensure correct permissions
chmod -R 777 /var/lib/headscale /var/run/headscale

echo "Starting Headscale with arguments: $@"
exec headscale "$@"