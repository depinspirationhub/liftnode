✅ Setup complete! Your node is now running inside the Docker container.

📡 To view your node's output inside the running screen session, use:
   docker exec -it lift bash -c "screen -r liftnode"

🖥️ To enter the Docker container manually, run:
   docker exec -it lift bash

🔄 To minimize the screen session while keeping the node running:
   Press CTRL + A, then press D

🚪 To detach from the Docker container after entering it, run:
   exit

🔍 To check if the node is still running inside screen, use:
   docker exec -it lift screen -ls

🎯 If you want to restart the node manually inside the container, use:
   docker exec lift screen -S liftnode -dm bash -c "cd /root/LIFTNode && ./node"

✅ Your LIFT Node is now set up and running! 🚀
