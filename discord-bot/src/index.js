require("dotenv").config();

const {
  Client,
  GatewayIntentBits,
} = require("discord.js");

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

client.once("ready", async () => {
  console.log(`Bot logged in as ${client.user.tag}`);

  try {
    const logsChannel = await client.channels.fetch(
      process.env.DISCORD_LOGS_CHANNEL_ID
    );

    await logsChannel.send(
      "🟢 Epic Gamers Minecraft bot is online."
    );

    console.log("Test message sent to #minecraft-logs");
  } catch (error) {
    console.error("Failed to send test message:", error);
  }
});

client.login(process.env.DISCORD_BOT_TOKEN);