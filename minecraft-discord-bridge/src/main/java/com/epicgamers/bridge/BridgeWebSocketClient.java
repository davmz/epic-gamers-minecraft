package com.epicgamers.bridge;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

public class BridgeWebSocketClient
    implements WebSocket.Listener {

    private static final String BRIDGE_URL =
        "ws://discord-bot.discord-bot.svc.cluster.local:3001";

    private static final int RECONNECT_DELAY_SECONDS = 5;

    private static final HttpClient HTTP_CLIENT =
        HttpClient.newHttpClient();

    private static final ScheduledExecutorService RECONNECT_EXECUTOR =
        Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread =
                new Thread(runnable, "discord-bridge-reconnect");

            thread.setDaemon(true);

            return thread;
        });

    private static final AtomicBoolean reconnectScheduled =
        new AtomicBoolean(false);

    private static volatile WebSocket webSocket;

    private BridgeWebSocketClient() {
    }

    // ---------------------------------------------------------
    // CONNECT
    // ---------------------------------------------------------

    public static void connect() {
        EpicGamersBridge.LOGGER.info(
            "Connecting to Discord bridge at {}",
            BRIDGE_URL
        );

        HTTP_CLIENT
            .newWebSocketBuilder()
            .buildAsync(
                URI.create(BRIDGE_URL),
                new BridgeWebSocketClient()
            )
            .thenAccept(socket -> {
                webSocket = socket;
                reconnectScheduled.set(false);

                EpicGamersBridge.LOGGER.info(
                    "Connected to Discord bridge."
                );
            })
            .exceptionally(error -> {
                EpicGamersBridge.LOGGER.error(
                    "Failed to connect to Discord bridge.",
                    error
                );

                webSocket = null;

                scheduleReconnect();

                return null;
            });
    }

    // ---------------------------------------------------------
    // RECONNECT
    // ---------------------------------------------------------

    private static void scheduleReconnect() {
        if (!reconnectScheduled.compareAndSet(false, true)) {
            return;
        }

        EpicGamersBridge.LOGGER.info(
            "Discord bridge reconnect scheduled in {} seconds.",
            RECONNECT_DELAY_SECONDS
        );

        RECONNECT_EXECUTOR.schedule(
            () -> {
                reconnectScheduled.set(false);
                connect();
            },
            RECONNECT_DELAY_SECONDS,
            TimeUnit.SECONDS
        );
    }

    // ---------------------------------------------------------
    // SEND MESSAGE
    // ---------------------------------------------------------

    public static void send(String message) {
        WebSocket socket = webSocket;

        if (socket == null) {
            EpicGamersBridge.LOGGER.warn(
                "Cannot send bridge message: WebSocket is not connected."
            );

            return;
        }

        socket.sendText(message, true)
            .exceptionally(error -> {
                EpicGamersBridge.LOGGER.error(
                    "Failed to send bridge message.",
                    error
                );

                webSocket = null;
                scheduleReconnect();

                return null;
            });
    }

    // ---------------------------------------------------------
    // WEBSOCKET OPEN
    // ---------------------------------------------------------

    @Override
    public void onOpen(WebSocket webSocket) {
        BridgeWebSocketClient.webSocket = webSocket;

        reconnectScheduled.set(false);

        EpicGamersBridge.LOGGER.info(
            "Minecraft Discord bridge WebSocket opened."
        );

        webSocket.request(1);
    }

    // ---------------------------------------------------------
    // MESSAGE FROM DISCORD BRIDGE
    // ---------------------------------------------------------

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

    // ---------------------------------------------------------
    // CONNECTION CLOSED
    // ---------------------------------------------------------

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

        scheduleReconnect();

        return null;
    }

    // ---------------------------------------------------------
    // CONNECTION ERROR
    // ---------------------------------------------------------

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

        scheduleReconnect();
    }
}