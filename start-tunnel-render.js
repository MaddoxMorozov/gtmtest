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

const sshConfig = {
    host: sshHost,
    port: 22,
    username: sshUser,
    privateKey: privateKey
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

(async () => {
    try {
        console.log('Starting SSH tunnel for Render...');
        console.log(`SSH target: ${sshUser}@${sshHost}`);
        console.log(`Forwarding localhost:${localPort} -> remote:${dbPort}`);

        const [server, connection] = await createTunnel(tunnelConfig, serverConfig, sshConfig, forwardConfig);

        console.log(`✓ SSH tunnel established on localhost:${localPort}`);
        console.log('Tunnel ready for n8n connections.');

        server.on('error', (err) => {
            console.error('Tunnel server error:', err);
        });

        connection.on('error', (err) => {
            console.error('SSH connection error:', err);
        });

        connection.on('close', () => {
            console.error('SSH connection closed! Tunnel is down.');
            process.exit(1);
        });

    } catch (error) {
        console.error('Failed to start tunnel:', error);
        process.exit(1);
    }
})();
