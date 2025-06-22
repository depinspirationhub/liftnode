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
if [[ "$AGREEMENT" != "y" ]]; then
    echo "You have declined the agreement. Exiting script."
    exit 1
fi

# Ask for container name
read -p "Enter a unique name for this container (e.g., lift1, lift2): " CONTAINER_NAME

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "A container named '$CONTAINER_NAME' already exists. Please choose a different name."
    exit 1
fi

echo "Proceeding with the setup for container: $CONTAINER_NAME..."

# Update and install dependencies
echo "Updating system and installing required packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker
docker --version

# Run Ubuntu container with interactive Bash shell
echo "Creating Docker container '$CONTAINER_NAME'..."
docker run -dit --name "$CONTAINER_NAME" --restart always ubuntu bash

# Wait briefly for container to start
sleep 5

# Install dependencies inside the container
echo "Installing dependencies inside the container..."
docker exec "$CONTAINER_NAME" apt-get update
docker exec "$CONTAINER_NAME" apt-get install -y wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Download LIFT Node files
echo "Downloading LIFT Node..."
wget -O LIFTNode_"$CONTAINER_NAME".zip https://studio.liftdata.ai/standalone_nodes/desktop-ubuntu-24.04-X64.zip
unzip LIFTNode_"$CONTAINER_NAME".zip -d LIFTNode_"$CONTAINER_NAME"

# Prompt user for API key
echo "You need an API key to proceed."
echo "🔹 Create your API key here: https://studio.liftdata.ai/api-keys"
echo ""

read -p "Enter your API key: " API_KEY

# Inject API key into settings.json
echo "Creating settings.json with API key..."
echo "{
  \"api_key\": \"$API_KEY\"
}" > LIFTNode_"$CONTAINER_NAME"/settings.json

# Copy files into the container
echo "Copying files into Docker container..."
docker cp LIFTNode_"$CONTAINER_NAME" "$CONTAINER_NAME":/root/LIFTNode

# Install Python dependencies inside the container
echo "Installing Python packages..."
docker exec "$CONTAINER_NAME" pip3 install --break-system-packages opencv-python-headless

# Start the node in a screen session inside the container
echo "Starting node inside screen session 'liftnode'..."
docker exec "$CONTAINER_NAME" screen -S liftnode -dm bash -c "cd /root/LIFTNode && ./node"

echo ""
echo "✅ LIFT Node is now running in container: $CONTAINER_NAME"
echo ""
echo "👉 To attach to the container shell:"
echo "   docker attach $CONTAINER_NAME"
echo ""
echo "👉 Once inside, to view node output:"
echo "   screen -r liftnode"
echo ""
echo "👉 To detach from screen (keep node running):"
echo "   Press CTRL + A, then D"
echo ""
echo "👉 To detach from container (keep container running):"
echo "   Press CTRL + P, then CTRL + Q"
echo ""
echo "👉 To check if screen is still running:"
echo "   docker exec -it $CONTAINER_NAME screen -ls"
echo ""
echo "👉 To stop and remove this container:"
echo "   docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
echo ""
