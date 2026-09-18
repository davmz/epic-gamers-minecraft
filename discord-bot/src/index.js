require("dotenv").config();

const {
  Client,
  GatewayIntentBits,
} = require("discord.js");

const {
  startMinecraftBridge,
} = require("./minecraft-bridge");

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

client.once("clientReady", async () => {
  console.log(`Bot logged in as ${client.user.tag}`);

  // Start Minecraft WebSocket bridge after Discord is ready
  startMinecraftBridge(client);

  try {
    const logsChannel = await client.channels.fetch(
      process.env.DISCORD_LOGS_CHANNEL_ID
    );

    if (!logsChannel?.isTextBased()) {
      throw new Error(
        "DISCORD_LOGS_CHANNEL_ID does not point to a text-based channel."
      );
    }

    await logsChannel.send(
      "🟢 Epic Gamers Minecraft bot is online."
    );

    console.log(
      "Bot online message sent to #minecraft-logs"
    );
  } catch (error) {
    console.error(
      "Failed to send bot online message:",
      error
    );
  }
});

client.on("error", (error) => {
  console.error("Discord client error:", error);
});

process.on("unhandledRejection", (error) => {
  console.error(
    "Unhandled promise rejection:",
    error
  );
});

client.login(process.env.DISCORD_BOT_TOKEN);