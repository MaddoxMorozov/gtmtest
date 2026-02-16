#!/bin/bash

# This script copies your SSH public key to the MySQL server
# Run this script and enter your SSH password when prompted

echo "=== SSH Key Setup Script ==="
echo ""
echo "Your public key:"
cat ~/.ssh/id_rsa.pub
echo ""
echo "---"
echo ""
echo "Step 1: Copying public key to server..."
echo "You will be prompted for the SSH password"
echo ""

# Copy the key to the server
ssh root@173.212.247.135 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Public key copied successfully!"
    echo ""
    echo "Step 2: Testing passwordless connection..."
    ssh -o BatchMode=yes root@173.212.247.135 "echo '✓ Passwordless SSH works!'" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Setup complete! You can now use SSH without password."
    else
        echo "⚠ Key was copied but passwordless login test failed."
        echo "Try: ssh root@173.212.247.135"
    fi
else
    echo "✗ Failed to copy key. Please check your password and try again."
fi
