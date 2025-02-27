#!/bin/bash

# Update and install dependencies
echo "Updating system and installing required packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker
docker --version

# Run Ubuntu container with Docker
echo "Setting up the Docker container..."
docker run -it --name lift --restart always ubuntu /bin/bash

# Download and set up LIFT Node
echo "Downloading LIFT Node..."
wget -O LIFTNode.zip https://studio.liftdata.ai/standalone_nodes/desktop-ubuntu-24.04-X64.zip
unzip LIFTNode.zip -d LIFTNode

# Prompt user for API key
read -p "Enter your API key: " API_KEY

# Insert API key into settings.json
echo "Configuring settings.json with your API key..."
echo "{
  \"api_key\": \"$API_KEY\"
}" > LIFTNode/settings.json

# Navigate to the LIFTNode directory
cd LIFTNode

# Start a new screen session
echo "Creating a new screen session for the node..."
screen -dmS lift

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --break-system-packages opencv-python-headless

# Start the node
echo "Starting the LIFT Node..."
./node

echo "Setup complete! Your node is now running."
