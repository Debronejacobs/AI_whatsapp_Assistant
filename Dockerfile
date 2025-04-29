# Use a Node.js base image that includes Debian, suitable for installing Python.
# Bullseye is newer than Buster.
FROM node:lts-bullseye-slim

# Set environment variables for non-interactive apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools: Python3, pip, and supervisor
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    # Python & Pip
    python3 \
    python3-pip \
    # Supervisor
    supervisor \
    # Clean up apt cache after successful install
    && rm -rf /var/lib/apt/lists/*

# Set the main working directory
WORKDIR /app

# --- Client Setup ---
# Copy client requirements first for caching
COPY ./client/requirements.txt /app/client/requirements.txt
# Install Python dependencies
RUN pip3 install --no-cache-dir -r /app/client/requirements.txt
# Copy the rest of the client application code
COPY ./client /app/client

# --- Server Setup ---
# Copy server package files first for caching
COPY ./server/package*.json /app/server/
# Set WORKDIR temporarily for npm install
WORKDIR /app/server
# Install Node.js dependencies
# Consider adding --omit=dev if you don't need devDependencies in production
# Note: If 'npm install' tries to download Puppeteer's browser, it might fail
# or download a version incompatible with this slim image without browser dependencies.
# You might need to configure Puppeteer to skip browser download if possible,
# or handle potential errors during npm install if it includes Puppeteer.
RUN npm install
# Copy the rest of the server application code
COPY ./server /app/server

# --- Supervisor Setup ---
# Copy the supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- Environment Variables ---
# Copy the .env file (optional, Koyeb might inject env vars directly)
COPY .env /app/.env
# Note: Both processes run by supervisor will inherit environment variables
# set in the container (either via Koyeb or this Dockerfile).

# Reset working directory (optional, good practice)
WORKDIR /app

# Expose the ports both services listen on
EXPOSE 8001
EXPOSE 3000

# Command to run supervisor, which in turn starts both services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
