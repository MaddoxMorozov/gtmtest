FROM n8nio/n8n:latest

USER root

# Install bash (already present in n8n image, but ensure it's available)
RUN apk add --no-cache bash openssh-client

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

# Use bash to run the startup script
ENTRYPOINT ["bash", "start.sh"]
