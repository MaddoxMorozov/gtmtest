#!/bin/bash

echo "=== Render Combined Startup ==="
echo ""

# Step 1: Install tunnel dependency
echo "Step 1: Installing tunnel-ssh..."
npm install tunnel-ssh
echo ""

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

echo "✓ Tunnel is running (PID: $TUNNEL_PID)"
echo ""

# Step 4: Start n8n
echo "Step 4: Starting n8n..."
npx n8n start
