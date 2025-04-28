# Use a Node.js base image based on Debian Slim, which is suitable for adding browser dependencies
FROM node:lts-buster-slim

# Set environment variables for non-interactive apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install Chromium and its required dependencies.
# Removed libxshmfence6 as it was not found.
# This list can be extensive as headless Chrome needs many libraries.
# --no-install-recommends helps keep the image smaller.
RUN apt-get clean && apt-get update && apt-get install -y \
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
    libwebp6 \
    libglib2.0-0 \
    libharfbuzz0b \
    libfreetype6 \
    libthai0 \
    libpangoft2-1.0-0 \
    libfribidi0 \
    libpixman-1-0 \
    libgtk-3-0 \
    libgconf-2-4 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* # Clean up apt cache after installation

# Set environment variable to tell Puppeteer where to find the browser executable.
# This path corresponds to where 'chromium' is installed by apt-get.
# ENV CHROME_PATH="/usr/bin/chromium"
# Note: whatsapp-web.js/puppeteer might prefer PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
# Source path is relative to the build context (./server)
COPY package*.json ./

# Install Node.js dependencies (this will install puppeteer)
RUN npm install

# Copy the rest of the application code from the server directory
# Source path '.' is relative to the build context (./server)
COPY . ./

# The CMD below just runs your npm start script. Ensure your script correctly launches whatsapp-web.js with the necessary puppeteer args.
CMD ["npm", "start"]