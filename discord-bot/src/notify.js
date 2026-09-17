const { REST, Routes } = require("discord.js");

const token = process.env.DISCORD_BOT_TOKEN;
const logsChannelId = process.env.DISCORD_LOGS_CHANNEL_ID;

if (!token) {
  console.error("DISCORD_BOT_TOKEN is not configured.");
  process.exit(1);
}

if (!logsChannelId) {
  console.error("DISCORD_LOGS_CHANNEL_ID is not configured.");
  process.exit(1);
}

const notifications = {
  "server-online": "🟢 **Minecraft server is online.**",
  "server-stopping": "🔴 **Minecraft server is shutting down.**",
};

const notificationType = process.argv[2];
const message = notifications[notificationType];

if (!message) {
  console.error(`Unknown notification type: ${notificationType}`);
  process.exit(1);
}

const rest = new REST({ version: "10" }).setToken(token);

async function sendNotification() {
  try {
    await rest.post(Routes.channelMessages(logsChannelId), {
      body: {
        content: message,
      },
    });

    console.log(`Discord notification sent: ${notificationType}`);
  } catch (error) {
    console.error("Failed to send Discord notification:", error);
    process.exit(1);
  }
}

sendNotification();