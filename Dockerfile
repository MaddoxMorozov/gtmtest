FROM n8nio/n8n:latest

USER root

# Set working directory
WORKDIR /app

# Copy package files and install tunnel dependency
COPY package.json ./
RUN npm install --production

# Copy application files
COPY start-tunnel-render.js ./
COPY start.sh ./
RUN chmod +x start.sh

# Copy workflow file (import manually into n8n or mount as volume)
COPY newvolgtmwa-fixed.json ./

# n8n default port
EXPOSE 5678

# Run startup script with sh (bash may not be available in minimal Alpine image)
ENTRYPOINT ["sh", "start.sh"]
