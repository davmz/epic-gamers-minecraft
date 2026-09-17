#!/usr/bin/env bash

set -e

echo "Stopping Discord bot..."

kubectl scale deployment discord-bot \
  -n discord-bot \
  --replicas=0

echo "Discord bot stopped."