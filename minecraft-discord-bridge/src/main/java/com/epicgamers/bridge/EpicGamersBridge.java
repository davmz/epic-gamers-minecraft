package com.epicgamers.bridge;

import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.entity.event.v1.ServerLivingEntityEvents;
import net.fabricmc.fabric.api.entity.event.v1.ServerPlayerEvents;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.damagesource.DamageSource;

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

        registerPlayerEvents();
    }

    private void registerPlayerEvents() {

        // -------------------------------------------------
        // PLAYER JOIN
        // -------------------------------------------------

        ServerPlayerEvents.JOIN.register(player -> {
            String playerName =
                player.getGameProfile().name();

            LOGGER.info(
                "Player joined: {}",
                playerName
            );

            BridgeWebSocketClient.send(
                """
                {
                  "type": "join",
                  "player": "%s"
                }
                """.formatted(playerName)
            );
        });

        // -------------------------------------------------
        // PLAYER LEAVE
        // -------------------------------------------------

        ServerPlayerEvents.LEAVE.register(player -> {
            String playerName =
                player.getGameProfile().name();

            LOGGER.info(
                "Player left: {}",
                playerName
            );

            BridgeWebSocketClient.send(
                """
                {
                  "type": "leave",
                  "player": "%s"
                }
                """.formatted(playerName)
            );
        });

        // -------------------------------------------------
        // PLAYER DEATH
        // -------------------------------------------------

        ServerLivingEntityEvents.AFTER_DEATH.register(
            (entity, damageSource) -> {

                if (!(entity instanceof ServerPlayer player)) {
                    return;
                }

                sendDeathEvent(player, damageSource);
            }
        );
    }

    private void sendDeathEvent(
        ServerPlayer player,
        DamageSource damageSource
    ) {
        String playerName =
            player.getGameProfile().name();

        String deathMessage =
            damageSource
                .getLocalizedDeathMessage(player)
                .getString();

        LOGGER.info(
            "Player died: {}",
            deathMessage
        );

        BridgeWebSocketClient.send(
            """
            {
            "type": "death",
            "player": "%s",
            "message": "%s"
            }
            """.formatted(
                escapeJson(playerName),
                escapeJson(deathMessage)
            )
        );
    }

    private static String escapeJson(String value) {
        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
    }
}