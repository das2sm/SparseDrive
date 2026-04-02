This document serves as the "Source of Truth" for your hybrid research environment on the **RTX 3090**. It ensures that both **SparseDrive** and **SparseOcc** can run simultaneously without dependency conflicts or lost progress.

---

## 🏗️ System Architecture
* **Host OS:** Ubuntu (Local Machine)
* **Container:** Docker (`sparsedrive_env`) running as a persistent environment.
* **Data:** External Drive mapped to `/workspace/SparseDrive/data/nuscenes`.
* **Repos:** Local folders for `SparseDrive` and `SparseOcc` mapped as volumes.

---

## 1. Directory Structure (Host)
Maintain this structure in `/home/ace428/Soham/` to ensure the startup scripts work:
```text
/home/ace428/Soham/
├── start_hybrid.sh     # Main launcher (Host)
├── init_hybrid.sh      # Environment setup (Inside Docker)
├── SparseDrive/        # Research Repo 1
└── SparseOcc/          # Research Repo 2
```

---

## 2. The Orchestration Scripts

### `start_hybrid.sh` (Host Launcher)
This script handles hardware access, network bridging for CARLA, and mounting all necessary volumes.
```bash
#!/bin/bash
DRIVE_REPO="/home/ace428/Soham/SparseDrive"
OCC_REPO="/home/ace428/Soham/SparseOcc"
NUSCENES_PATH="/media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes"
IMAGE_NAME="sparsedrive_env"

sudo docker run --gpus all -it \
    --shm-size=16G \
    --network host \
    -v ${DRIVE_REPO}:/workspace/SparseDrive \
    -v ${OCC_REPO}:/workspace/SparseOcc \
    -v ${NUSCENES_PATH}:/workspace/SparseDrive/data/nuscenes \
    -v /home/ace428/Soham/init_hybrid.sh:/workspace/init_hybrid.sh \
    ${IMAGE_NAME} /bin/bash -c "/workspace/init_hybrid.sh"
```

### `init_hybrid.sh` (Container Initialization)
This script runs automatically inside the container to fix paths and dependencies.
```bash
#!/bin/bash
# 1. Set Python Paths
export PYTHONPATH=/workspace:/workspace/SparseDrive:/workspace/SparseOcc:/workspace/SparseDrive/projects

# 2. Fix MMCV Version Check (Required for SparseDrive/Occ compatibility)
sed -i 's/1.7.1/1.7.0/g' /usr/local/lib/python3.8/dist-packages/mmcv/version.py 2>/dev/null

# 3. Handle Data Symlinks
if [ ! -d "/workspace/SparseOcc/data/nuscenes" ]; then
    mkdir -p /workspace/SparseOcc/data
    ln -s /workspace/SparseDrive/data/nuscenes /workspace/SparseOcc/data/nuscenes
fi

echo "✅ HYBRID ENVIRONMENT READY"
cd /workspace
exec bash
```

---

## 3. Core Dependencies (Baked into Image)
The following packages must be present in the `sparsedrive_env` image to avoid runtime errors:

| Category | Package & Version |
| :--- | :--- |
| **Foundational** | `numba`, `wandb`, `lyft-dataset-sdk`, `nuscenes-devkit` |
| **Geometry** | `trimesh==2.35.39`, `scikit-image`, `plyfile`, `networkx<2.3` |
| **Simulator** | `carla==0.9.14` |
| **Perception** | `mmcv-full==1.7.0`, `mmdet3d==1.0.0rc6` |

---

## 4. Maintenance Commands

### Compiling SparseOcc CUDA Operators
If you see a `ModuleNotFoundError` for `_msmv_sampling_cuda`, run this inside the container:
```bash
cd /workspace/SparseOcc/models/csrc
python3 setup.py develop
```

### Saving Your Progress (The Commit)
Since Docker containers are ephemeral, **always commit your changes** to the image after installing new `pip` packages:
```bash
# On Host Machine
docker commit <container_id> sparsedrive_env
```

---

## 5. Verification Checklist
Run these to ensure the "Brain" is functional:
* **SparseOcc Check:** `python3 -c "from models.csrc.wrapper import msmv_sampling; print('✅ SparseOcc OK')"`
* **SparseDrive Check:** `python3 -c "import mmdet3d; print('✅ SparseDrive OK')"` (Ignore NuScenes3DDataset KeyErrors; they confirm the plugin is found).
* **Data Check:** `ls /workspace/SparseOcc/data/nuscenes` (Should list `v1.0-trainval`).

---
