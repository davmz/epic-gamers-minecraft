const { WebSocketServer } = require("ws");

const BRIDGE_PORT = 3001;

function startMinecraftBridge() {
  const wss = new WebSocketServer({
    port: BRIDGE_PORT,
  });

  console.log(
    `Minecraft bridge WebSocket server listening on port ${BRIDGE_PORT}`
  );

  wss.on("connection", (socket, request) => {
    const remoteAddress = request.socket.remoteAddress;

    console.log(
      `Minecraft bridge client connected from ${remoteAddress}`
    );

    socket.on("message", (data) => {
      try {
        const message = JSON.parse(data.toString());

        console.log("Minecraft bridge message received:");
        console.log(message);
      } catch (error) {
        console.error(
          "Minecraft bridge received invalid JSON:",
          error.message
        );
      }
    });

    socket.on("close", () => {
      console.log("Minecraft bridge client disconnected");
    });

    socket.on("error", (error) => {
      console.error(
        "Minecraft bridge WebSocket error:",
        error
      );
    });

    socket.send(
      JSON.stringify({
        type: "connected",
        message: "Connected to Epic Gamers Minecraft Discord bridge",
      })
    );
  });

  wss.on("error", (error) => {
    console.error(
      "Minecraft bridge server error:",
      error
    );
  });

  return wss;
}

module.exports = {
  startMinecraftBridge,
};