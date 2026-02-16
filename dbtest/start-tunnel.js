const { createTunnel } = require('tunnel-ssh');
const fs = require('fs');
const path = require('path');

const keyPath = path.join(__dirname, '..', 'id_rsa_mysql.txt');

const sshConfig = {
    host: '173.212.247.135',
    port: 22,
    username: 'root',
    privateKey: fs.readFileSync(keyPath)
};

const tunnelConfig = {
    autoClose: false // Keep alive
};

const serverConfig = {
    port: 3307
};

const forwardConfig = {
    srcAddr: '127.0.0.1',
    srcPort: 3307,
    dstAddr: '127.0.0.1',
    dstPort: 3306
};

(async () => {
    try {
        console.log('Starting SSH tunnel...');
        console.log(`Using key: ${keyPath}`);
        
        const [server, connection] = await createTunnel(tunnelConfig, serverConfig, sshConfig, forwardConfig);
        
        console.log('✓ SSH tunnel established on localhost:3307');
        console.log('Ready for connections...');
        console.log('(Press Ctrl+C to stop)');

        server.on('error', (err) => {
            console.error('Tunnel server error:', err);
        });

    } catch (error) {
        console.error('Failed to start tunnel:', error);
    }
})();
