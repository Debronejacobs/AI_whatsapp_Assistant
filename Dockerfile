# Use a Node.js base image that includes Debian, suitable for installing Python and Chromium deps.
# Bullseye is newer than Buster.
FROM node:lts-bullseye-slim

# Set environment variables for non-interactive apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools, Python3, pip, supervisor, and Chromium + dependencies
# Trying a curated list known to work for Puppeteer on Debian
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python & Pip
    python3 \
    python3-pip \
    # Supervisor
    supervisor \
    # Minimal Dependencies for Puppeteer-downloaded Chromium
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    wget \
    xdg-utils \
    # Clean up apt cache after successful install
    && rm -rf /var/lib/apt/lists/*

# Set the main working directory
WORKDIR /app

# --- Client Setup ---
COPY ./client/requirements.txt /app/client/requirements.txt
RUN pip3 install --no-cache-dir -r /app/client/requirements.txt
COPY ./client /app/client

# --- Server Setup ---
COPY ./server/package*.json /app/server/
WORKDIR /app/server
RUN npm install
COPY ./server /app/server

# --- Supervisor Setup ---
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- Environment Variables ---
# REMOVED: COPY .env /app/.env
# Environment variables should be injected by the deployment platform (Koyeb).

WORKDIR /app

# Expose the ports both services listen on
EXPOSE 8001
EXPOSE 3000

# Command to run supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
