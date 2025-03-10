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
echo "You need an API key to proceed."
echo "🔹 Create your API key here: https://studio.liftdata.ai/api-keys"
echo "🔹 Follow this guide on how to create an API key: https://docs.liftdata.ai/lift-ecosystem/nodes/installing-nodes"
echo ""

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

echo "Setup complete! Your node is now running inside the Docker container."
echo ""
echo "Please wait about 1 minute after running this command. The node takes time to initialize."
echo "To view your node's output inside the running screen session, use:"
echo "   docker exec -it lift bash -c \"screen -r liftnode\""
echo ""
echo "To enter the Docker container manually, run:"
echo "   docker exec -it lift bash"
echo ""
echo "To minimize the screen session while keeping the node running:"
echo "   Press CTRL + A, then press D"
echo ""
echo "To detach from the Docker container after entering it, run:"
echo "   exit"
echo ""
echo "To check if the node is still running inside screen, use:"
echo "   docker exec -it lift screen -ls"
echo ""
echo "If you want to restart the node manually inside the container, use:"
echo "   docker exec lift screen -S liftnode -dm bash -c \"cd /root/LIFTNode && ./node\""
echo ""
echo "To stop and remove the Docker container, use:"
echo "   docker stop lift && docker rm lift"
echo ""
echo "Your LIFT Node is now set up and running!"
