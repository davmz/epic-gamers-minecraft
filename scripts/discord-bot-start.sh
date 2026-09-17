#!/usr/bin/env bash

set -e

echo "Starting Discord bot..."

kubectl scale deployment discord-bot \
  -n discord-bot \
  --replicas=1

echo "Waiting for Discord bot rollout..."

kubectl rollout status deployment discord-bot \
  -n discord-bot

echo "Discord bot started."