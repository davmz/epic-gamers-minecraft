package com.epicgamers.bridge;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletionStage;

public class BridgeWebSocketClient
    implements WebSocket.Listener {

    private static final String BRIDGE_URL =
        "ws://discord-bot.discord-bot.svc.cluster.local:3001";

    private static WebSocket webSocket;

    private BridgeWebSocketClient() {
    }

    public static void connect() {
        EpicGamersBridge.LOGGER.info(
            "Connecting to Discord bridge at {}",
            BRIDGE_URL
        );

        HttpClient client =
            HttpClient.newHttpClient();

        client.newWebSocketBuilder()
            .buildAsync(
                URI.create(BRIDGE_URL),
                new BridgeWebSocketClient()
            )
            .thenAccept(socket -> {
                webSocket = socket;

                EpicGamersBridge.LOGGER.info(
                    "Connected to Discord bridge."
                );
            })
            .exceptionally(error -> {
                EpicGamersBridge.LOGGER.error(
                    "Failed to connect to Discord bridge.",
                    error
                );

                return null;
            });
    }

    public static void send(String message) {
        if (webSocket == null) {
            EpicGamersBridge.LOGGER.warn(
                "Cannot send bridge message: WebSocket is not connected."
            );

            return;
        }

        webSocket.sendText(message, true)
            .exceptionally(error -> {
                EpicGamersBridge.LOGGER.error(
                    "Failed to send bridge message.",
                    error
                );

                return null;
            });
    }

    @Override
    public void onOpen(WebSocket webSocket) {
        EpicGamersBridge.LOGGER.info(
            "Minecraft Discord bridge WebSocket opened."
        );

        webSocket.request(1);
    }

    @Override
    public CompletionStage<?> onText(
        WebSocket webSocket,
        CharSequence data,
        boolean last
    ) {
        EpicGamersBridge.LOGGER.info(
            "Bridge message received: {}",
            data
        );

        webSocket.request(1);

        return null;
    }

    @Override
    public CompletionStage<?> onClose(
        WebSocket webSocket,
        int statusCode,
        String reason
    ) {
        EpicGamersBridge.LOGGER.warn(
            "Discord bridge disconnected. Code: {}, reason: {}",
            statusCode,
            reason
        );

        BridgeWebSocketClient.webSocket = null;

        return null;
    }

    @Override
    public void onError(
        WebSocket webSocket,
        Throwable error
    ) {
        EpicGamersBridge.LOGGER.error(
            "Discord bridge WebSocket error.",
            error
        );

        BridgeWebSocketClient.webSocket = null;
    }
}