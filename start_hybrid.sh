#!/bin/bash
# ============================================================
# Hybrid Sparse Perception Startup (Drive + Occ)
# ============================================================

DRIVE_REPO="/home/ace428/Soham/SparseDrive"
OCC_REPO="/home/ace428/Soham/SparseOcc"  # <--- NEW: Path to your SparseOcc repo
NUSCENES_PATH="/media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes"
IMAGE_NAME="sparsedrive_env" # Use your committed image or the base one

# ---- Check paths ----
if [ ! -d "$NUSCENES_PATH" ]; then
    echo "ERROR: nuScenes drive not found at $NUSCENES_PATH"
    exit 1
fi

if [ ! -d "$OCC_REPO" ]; then
    echo "ERROR: SparseOcc folder not found at $OCC_REPO"
    exit 1
fi

echo "Starting Hybrid Sparse Container..."

sudo docker run --gpus all -it \
    --shm-size=16G \
    --network host \
    -v ${DRIVE_REPO}:/workspace/SparseDrive \
    -v ${OCC_REPO}:/workspace/SparseOcc \
    -v ${NUSCENES_PATH}:/workspace/SparseDrive/data/nuscenes \
    -v /home/ace428/Soham/init_hybrid.sh:/workspace/init_hybrid.sh \
    ${IMAGE_NAME} /bin/bash -c "/workspace/init_hybrid.sh"