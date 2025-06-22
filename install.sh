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

# Ask how many containers to create
read -p "How many LIFT node instances (licenses) do you want to deploy? " INSTANCE_COUNT
if ! [[ "$INSTANCE_COUNT" =~ ^[0-9]+$ ]] || [ "$INSTANCE_COUNT" -lt 1 ]; then
    echo "Invalid number of instances."
    exit 1
fi

# Prompt for API key
echo "You need an API key to proceed."
echo "🔹 Create your API key here: https://studio.liftdata.ai/api-keys"
read -p "Enter your API key (will be used for all instances): " API_KEY

# Update and install system dependencies
echo "Updating system and installing required packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io wget unzip nano screen python3-pip libgl1 libglib2.0-0

# Enable and start Docker
echo "Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Download and prepare the node software once
if [ ! -f "LIFTNode.zip" ]; then
    echo "Downloading LIFT Node..."
    wget -O LIFTNode.zip https://studio.liftdata.ai/standalone_nodes/desktop-ubuntu-24.04-X64.zip
fi

# Extract once
rm -rf LIFTNode_shared
unzip LIFTNode.zip -d LIFTNode_shared

# Inject API key into shared settings.json
echo "{
  \"api_key\": \"$API_KEY\"
}" > LIFTNode_shared/settings.json

# Begin loop to create containers
for i in $(seq 1 "$INSTANCE_COUNT"); do
    CONTAINER_NAME="liftnode$i"

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "⚠️  Container '$CONTAINER_NAME' already exists. Skipping..."
        continue
    fi

    echo ""
    echo "🚀 Setting up instance $i of $INSTANCE_COUNT: $CONTAINER_NAME"

    # Run Ubuntu container
    docker run -dit --name "$CONTAINER_NAME" --restart always ubuntu bash

    # Wait briefly for container to initialize
    sleep 3

    # Install dependencies inside container
    docker exec "$CONTAINER_NAME" apt-get update
    docker exec "$CONTAINER_NAME" apt-get install -y wget unzip nano screen python3-pip libgl1 libglib2.0-0

    # Copy shared node folder into container
    docker cp LIFTNode_shared "$CONTAINER_NAME":/root/LIFTNode

    # Install Python dependencies
    docker exec "$CONTAINER_NAME" pip3 install --break-system-packages opencv-python-headless

    # Start the node inside a screen session
    docker exec "$CONTAINER_NAME" screen -S liftnode -dm bash -c "cd /root/LIFTNode && ./node"

    echo "✅ $CONTAINER_NAME setup complete and node started."
done

# Wrap up
echo ""
echo "🎉 All $INSTANCE_COUNT instance(s) processed."
echo ""
echo "👉 You can attach to any container using:"
echo "   docker attach liftnode1  (or liftnode2, etc.)"
echo ""
echo "👉 Once inside, view node logs using:"
echo "   screen -r liftnode"
echo ""
echo "👉 Detach from screen with: CTRL + A, then D"
echo "👉 Detach from container with: CTRL + P, then CTRL + Q"
echo ""
echo "👉 To stop and remove a container:"
echo "   docker stop liftnode1 && docker rm liftnode1"
echo ""
