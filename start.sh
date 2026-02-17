#!/bin/bash

echo "=== Render Combined Startup ==="
echo ""

# Step 1: Install tunnel dependency (skip if already installed by Docker build)
if [ ! -d "node_modules/tunnel-ssh" ]; then
  echo "Step 1: Installing tunnel-ssh..."
  npm install tunnel-ssh
  echo ""
else
  echo "Step 1: tunnel-ssh already installed, skipping."
fi

# Step 2: Start SSH tunnel in background
echo "Step 2: Starting SSH tunnel..."
node start-tunnel-render.js &
TUNNEL_PID=$!

# Step 3: Wait for tunnel to be ready
echo "Step 3: Waiting for tunnel to establish..."
sleep 5

# Check if tunnel process is still running
if ! kill -0 $TUNNEL_PID 2>/dev/null; then
    echo "ERROR: Tunnel process died! Check SSH_PRIVATE_KEY env var."
    exit 1
fi

echo "Tunnel is running (PID: $TUNNEL_PID)"
echo ""

# Step 4: Start n8n
# Use 'n8n' directly if available (Docker image), fall back to npx
echo "Step 4: Starting n8n..."
if command -v n8n &> /dev/null; then
  n8n start
else
  npx n8n start
fi
