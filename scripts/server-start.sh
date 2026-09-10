#!/usr/bin/env bash

set -e

CLUSTER_NAME="egm-prod"
NAMESPACE="minecraft"
DEPLOYMENT="minecraft"

echo "Starting Minecraft server..."

# ---------------------------------------------------------
# GET EKS NODE GROUP
# ---------------------------------------------------------

NODE_GROUP=$(aws eks list-nodegroups \
  --cluster-name "$CLUSTER_NAME" \
  --query "nodegroups[0]" \
  --output text)

echo "Node group: $NODE_GROUP"

# ---------------------------------------------------------
# SCALE EKS NODE GROUP UP
# ---------------------------------------------------------

aws eks update-nodegroup-config \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODE_GROUP" \
  --scaling-config minSize=1,maxSize=2,desiredSize=1

echo "Waiting for EKS node to become Ready..."

kubectl wait \
  --for=condition=Ready \
  node \
  --all \
  --timeout=600s

# ---------------------------------------------------------
# START MINECRAFT
# ---------------------------------------------------------

kubectl scale deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --replicas=1

echo "Waiting for Minecraft pod..."

kubectl rollout status deployment/"$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --timeout=600s

echo ""
echo "Minecraft server is running."

kubectl get pods -n "$NAMESPACE"