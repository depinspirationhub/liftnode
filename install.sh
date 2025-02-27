#!/bin/bash

# Disclaimer
echo "************************************************************"
echo "* DISCLAIMER:                                              *"
echo "* This script is created by DEPINspirationHUB and is      *"
echo "* partially AI-generated. It is provided AS-IS without    *"
echo "* any warranties or guarantees. Use at your own risk.     *"
echo "* I (DEPINspirationHUB) will not be held liable for any   *"
echo "* issues, damages, or losses caused by running this script. *"
echo "************************************************************"

# Prompt user to agree to the disclaimer
read -p "Do you agree to proceed? (y/n): " AGREEMENT

# Check user input
if [[ "$AGREEMENT" != "y" ]]; then
    echo "You have declined the agreement. Exiting script."
    exit 1
fi

echo "Proceeding with the setup..."

# Update and install dependencies
echo "Updating system and installing required packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker
docker --version

# Run Ubuntu container in detached mode
echo "Setting up the Docker container..."
docker run -d --name lift --restart always ubuntu sleep infinity

# Wait for the container to start
sleep 5

# Install dependencies inside the container
echo "Installing dependencies inside the container..."
docker exec lift apt-get update
docker exec lift apt-get install -y wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Ensure screen is installed
echo "Ensuring 'screen' is installed inside the container..."
docker exec lift apt-get install -y screen

# Download LIFT Node files
echo "Downloading LIFT Node..."
wget -O LIFTNode.zip https://studio.liftdata.ai/standalone_nodes/desktop-ubuntu-24.04-X64.zip
unzip LIFTNode.zip -d LIFTNode

# Prompt user for API key
read -p "Enter your API key: " API_KEY

# Inject API key into settings.json
echo "{
  \"api_key\": \"$API_KEY\"
}" > LIFTNode/settings.json

# Copy files into the container
echo "Copying LIFT Node files into the container..."
docker cp LIFTNode lift:/root/LIFTNode

# Install Python dependencies inside the container
echo "Installing Python dependencies inside the container..."
docker exec lift pip3 install --break-system-packages opencv-python-headless

# Start the node inside a screen session called "liftnode"
echo "Starting the LIFT Node inside a screen session named 'liftnode'..."
docker exec lift screen -S liftnode -dm bash -c "cd /root/LIFTNode && ./node"

echo "✅ Setup complete! Your node is now running inside the Docker container."
echo "📡 To view your node's output, attach to the screen session:"
echo "   docker exec -it lift screen -r liftnode"
echo "🖥️ To enter the container manually, run:"
echo "   docker exec -it lift bash"
