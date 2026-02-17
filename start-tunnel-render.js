const { createTunnel } = require('tunnel-ssh');

// On Render, the SSH private key comes from the environment variable
const privateKey = process.env.SSH_PRIVATE_KEY;
if (!privateKey) {
    console.error('ERROR: SSH_PRIVATE_KEY environment variable is not set!');
    process.exit(1);
}

const sshHost = process.env.SSH_HOST || '173.212.247.135';
const sshUser = process.env.SSH_USER || 'root';
const dbPort = parseInt(process.env.DB_PORT || '3306', 10);
const localPort = parseInt(process.env.LOCAL_PORT || '3307', 10);

const RECONNECT_DELAY_MS = 5000; // Wait 5 seconds before reconnecting
const MAX_RECONNECT_ATTEMPTS = 50; // Max consecutive failures before giving up
let reconnectAttempts = 0;

async function startTunnel() {
    const sshConfig = {
        host: sshHost,
        port: 22,
        username: sshUser,
        privateKey: privateKey,
        keepaliveInterval: 30000,  // Send keepalive every 30 seconds
        keepaliveCountMax: 5,      // Allow 5 missed keepalives before disconnect
        readyTimeout: 30000        // 30 second connection timeout
    };

    const tunnelConfig = {
        autoClose: false
    };

    const serverConfig = {
        port: localPort
    };

    const forwardConfig = {
        srcAddr: '127.0.0.1',
        srcPort: localPort,
        dstAddr: '127.0.0.1',
        dstPort: dbPort
    };

    try {
        console.log('Starting SSH tunnel for Render...');
        console.log(`SSH target: ${sshUser}@${sshHost}`);
        console.log(`Forwarding localhost:${localPort} -> remote:${dbPort}`);

        const [server, connection] = await createTunnel(tunnelConfig, serverConfig, sshConfig, forwardConfig);

        console.log(`✓ SSH tunnel established on localhost:${localPort}`);
        console.log('Tunnel ready for n8n connections.');

        // Reset reconnect counter on successful connection
        reconnectAttempts = 0;

        server.on('error', (err) => {
            console.error('Tunnel server error:', err);
        });

        connection.on('error', (err) => {
            console.error('SSH connection error:', err);
        });

        server.on('close', () => {
            console.log('Tunnel server closed.');
        });

        connection.on('close', () => {
            console.error('SSH connection closed! Tunnel is down.');
            console.log(`Will attempt to reconnect in ${RECONNECT_DELAY_MS / 1000} seconds...`);

            // Close the local server so port is freed for reconnect
            try { server.close(); } catch (e) { /* ignore */ }

            scheduleReconnect();
        });

    } catch (error) {
        console.error('Failed to start tunnel:', error.message || error);
        scheduleReconnect();
    }
}

function scheduleReconnect() {
    reconnectAttempts++;
    if (reconnectAttempts > MAX_RECONNECT_ATTEMPTS) {
        console.error(`Exceeded ${MAX_RECONNECT_ATTEMPTS} reconnect attempts. Giving up.`);
        process.exit(1);
    }
    console.log(`Reconnect attempt ${reconnectAttempts}/${MAX_RECONNECT_ATTEMPTS} in ${RECONNECT_DELAY_MS / 1000}s...`);
    setTimeout(() => {
        startTunnel();
    }, RECONNECT_DELAY_MS);
}

// Start the tunnel
startTunnel();
