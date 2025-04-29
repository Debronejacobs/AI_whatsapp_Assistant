# Use a Node.js base image that includes Debian, suitable for installing Python and Chromium deps.
# Bullseye is newer than Buster.
FROM node:lts-bullseye-slim

# Set environment variables for non-interactive apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools, Python3, pip, supervisor, and Chromium + dependencies
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    # Python & Pip
    python3 \
    python3-pip \
    # Supervisor
    supervisor \
    # Chromium and its dependencies (from your server Dockerfile)
    chromium \
    fonts-freefont-ttf \
    libgbm-dev \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm-dev \
    libxkbcommon-dev \
    libatspi2.0-0 \
    libnss3 \
    libxrandr2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libexpat1 \
    libxcb1 \
    libx11-6 \
    libasound2 \
    libpangocairo-1.0-0 \
    libcairo2 \
    libfontconfig1 \
    libjpeg62-turbo \
    libpng16-16 \
    libwebp7 \ # Note: libwebp6 might be libwebp7 on Bullseye
    libglib2.0-0 \
    libharfbuzz0b \
    libfreetype6 \
    libthai0 \
    libpangoft2-1.0-0 \
    libfribidi0 \
    libpixman-1-0 \
    libgtk-3-0 \
#   libgconf-2-4 \ # <<< REMOVED THIS PACKAGE
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
RUN npm install
# Copy the rest of the server application code
COPY ./server /app/server

# --- Supervisor Setup ---
# Copy the supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- Environment Variables ---
# Copy the .env file (optional, Koyeb might inject env vars directly)
# If you rely on Koyeb's env var injection, you can skip this line.
COPY .env /app/.env
# Note: Both processes run by supervisor will inherit environment variables
# set in the container (either via Koyeb or this Dockerfile).
# If client and server need DIFFERENT values for the SAME variable name,
# you might need to adjust the supervisord.conf [program:...] sections
# to include specific `environment=KEY="value",OTHER="value"` lines.

# Reset working directory (optional, good practice)
WORKDIR /app

# Expose the ports both services listen on
EXPOSE 8001
EXPOSE 3000

# Command to run supervisor, which in turn starts both services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
