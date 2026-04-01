#!/bin/bash
# ============================================================
# SparseDrive Docker Startup Script
# Usage: sh start_sparsedrive.sh
# ============================================================

REPO_PATH="/home/ace428/Soham/SparseDrive"
NUSCENES_PATH="/media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes"
IMAGE_NAME="sparsedrive_env"

# ---- Check external drive is mounted ----
if [ ! -d "$NUSCENES_PATH" ]; then
    echo "ERROR: nuScenes drive not mounted at $NUSCENES_PATH"
    echo "Please plug in the external drive and try again."
    exit 1
fi

echo "nuScenes drive found."
echo "Starting SparseDrive container..."

sudo docker run --gpus all -it \
    -v ${REPO_PATH}:/workspace/SparseDrive \
    -v ${NUSCENES_PATH}:/workspace/SparseDrive/data/nuscenes \
    ${IMAGE_NAME} bash