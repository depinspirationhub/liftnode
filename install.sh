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

# Run Ubuntu container interactively
echo "Setting up the Docker container..."
docker run -it --name lift --restart always ubuntu /bin/bash << 'EOF'
  echo "Updating container..."
  apt-get update && apt-get upgrade -y
  
  echo "Installing required packages..."
  apt-get install -y wget unzip nano screen python3-pip libgl1 libglib2.0-0
  
  echo "Downloading LIFT Node..."
  wget -O LIFTNode.zip https://studio.liftdata.ai/standalone_nodes/desktop-ubuntu-24.04-X64.zip
  unzip LIFTNode.zip -d LIFTNode

  # Prompt user for API key
  read -p "Enter your API key: " API_KEY

  # Inject API key into settings.json
  echo "{
    \"api_key\": \"$API_KEY\"
  }" > LIFTNode/settings.json

  echo "Installing Python dependencies..."
  pip3 install --break-system-packages opencv-python-headless

  echo "Starting a screen session for the node..."
  screen -S lift -dm bash -c "cd LIFTNode && ./node"

  echo "Setup complete! Your node is now running."
  echo "To check logs, type: screen -r lift"
EOF

# Let the user know they can reattach to the screen session
echo "To enter the container later, run: docker exec -it lift bash"
