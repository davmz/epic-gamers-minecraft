const { WebSocketServer } = require("ws");

const BRIDGE_PORT = 3001;

function startMinecraftBridge(client) {
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

    socket.on("message", async (data) => {
      try {
        const event = JSON.parse(data.toString());

        console.log("Minecraft bridge message received:");
        console.log(event);

        await handleMinecraftEvent(client, event);
      } catch (error) {
        console.error(
          "Failed to process Minecraft bridge message:",
          error
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
        message:
          "Connected to Epic Gamers Minecraft Discord bridge",
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

async function handleMinecraftEvent(client, event) {
  const channelId =
    process.env.DISCORD_CHAT_CHANNEL_ID;

  if (!channelId) {
    console.error(
      "DISCORD_CHAT_CHANNEL_ID is not configured."
    );
    return;
  }

  const channel =
    await client.channels.fetch(channelId);

  if (!channel?.isTextBased()) {
    console.error(
      "DISCORD_CHAT_CHANNEL_ID does not point to a text channel."
    );
    return;
  }

  let message;

  switch (event.type) {
    case "join":
      message =
        `🟢 **${event.player} joined the game**`;
      break;

    case "leave":
      message =
        `🔴 **${event.player} left the game**`;
      break;

    case "death":
      message =
        `💀 **${event.message}**`;
      break;

    default:
      console.log(
        `Ignoring unsupported Minecraft event: ${event.type}`
      );
      return;
  }

  await channel.send(message);

  console.log(
    `Minecraft ${event.type} event sent to Discord`
  );
}

module.exports = {
  startMinecraftBridge,
};