package com.epicgamers.bridge;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EpicGamersBridge implements ModInitializer {

    public static final String MOD_ID =
        "epic_gamers_discord_bridge";

    public static final Logger LOGGER =
        LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info(
            "Starting Epic Gamers Discord Bridge..."
        );

        BridgeWebSocketClient.connect();
    }
}