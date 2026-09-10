#!/usr/bin/env bash

set -e

CLUSTER_NAME="egm-prod"
NAMESPACE="minecraft"
DEPLOYMENT="minecraft"

echo "Stopping Minecraft server..."

# ---------------------------------------------------------
# SCALE MINECRAFT DOWN
# ---------------------------------------------------------

kubectl scale deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --replicas=0

echo "Waiting for Minecraft pod to stop..."

kubectl wait \
  --for=delete \
  pod \
  -l app=minecraft \
  -n "$NAMESPACE" \
  --timeout=120s || true

# ---------------------------------------------------------
# GET EKS NODE GROUP
# ---------------------------------------------------------

NODE_GROUP=$(aws eks list-nodegroups \
  --cluster-name "$CLUSTER_NAME" \
  --query "nodegroups[0]" \
  --output text)

echo "Node group: $NODE_GROUP"

# ---------------------------------------------------------
# SCALE EKS NODE GROUP TO ZERO
# ---------------------------------------------------------

aws eks update-nodegroup-config \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODE_GROUP" \
  --scaling-config minSize=0,maxSize=2,desiredSize=0

echo ""
echo "Shutdown requested."
echo "Minecraft: 0 replicas"
echo "EKS node group: scaling to 0"