#!/bin/bash

# Deployment script for MySQL connection setup
# Usage: ./deploy.sh user@server-ip

if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh user@server-ip"
    echo "Example: ./deploy.sh root@192.168.1.100"
    exit 1
fi

SERVER=$1
REMOTE_DIR="~/mysql-app"

echo "=== Deploying MySQL Connection to $SERVER ==="
echo ""

# Step 1: Copy SSH key
echo "Step 1: Copying SSH automation key..."
scp ~/.ssh/id_rsa_mysql "$SERVER:~/.ssh/" || { echo "Failed to copy SSH key"; exit 1; }
echo "✓ SSH key copied"
echo ""

# Step 2: Copy application files
echo "Step 2: Copying application files..."
scp db-automation.js "$SERVER:$REMOTE_DIR/" || { echo "Failed to copy db-automation.js"; exit 1; }
scp package.json "$SERVER:$REMOTE_DIR/" || { echo "Failed to copy package.json"; exit 1; }
echo "✓ Application files copied"
echo ""

# Step 3: Setup on server
echo "Step 3: Setting up on server..."
ssh "$SERVER" << 'EOF'
    # Set correct permissions
    chmod 600 ~/.ssh/id_rsa_mysql
    echo "✓ Key permissions set (600)"

    # Create directory if needed
    mkdir -p ~/mysql-app
    cd ~/mysql-app

    # Install dependencies
    echo ""
    echo "Installing Node.js dependencies..."
    npm install mysql2 ssh2 --save

    echo ""
    echo "✓ Setup complete!"
    echo ""
    echo "Testing connection..."

    # Test SSH key
    ssh -i ~/.ssh/id_rsa_mysql -o BatchMode=yes -o ConnectTimeout=5 root@173.212.247.135 "echo '✓ SSH key works'" 2>/dev/null || echo "⚠ SSH key test failed"

    # Test Node.js app
    echo ""
    echo "Running database test..."
    node db-automation.js
EOF

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "To run on the server:"
echo "  ssh $SERVER"
echo "  cd ~/mysql-app"
echo "  node db-automation.js"
