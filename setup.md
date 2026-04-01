# SparseDrive Docker Setup Guide

## One-Time Setup (Do This Once)

### 1. Clone the repo
```bash
cd /home/ace428/Soham
git clone https://github.com/swc-17/SparseDrive.git
cd SparseDrive
```

### 2. Set up data symlink
```bash
mkdir -p data
ln -s /media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes ./data/nuscenes
```

### 3. Build the Docker image
```bash
docker build -t sparsedrive_env .
```
This takes 30-60 minutes. Only needs to be done once.

### 4. Download pretrained weights
```bash
mkdir -p ckpt
wget https://download.pytorch.org/models/resnet50-19c8e357.pth -O ckpt/resnet50-19c8e357.pth
wget https://github.com/swc-17/SparseDrive/releases/download/v1.0/sparsedrive_stage1.pth -O ckpt/sparsedrive_stage1.pth
wget https://github.com/swc-17/SparseDrive/releases/download/v1.0/sparsedrive_stage2.pth -O ckpt/sparsedrive_stage2.pth
```

### 5. Generate nuScenes info files (takes ~40 minutes, only once)
Run this inside the container:
```bash
# Start container first (see below), then:
cd /workspace/SparseDrive
export PYTHONPATH="$(pwd)":$PYTHONPATH
python3 tools/data_converter/nuscenes_converter.py nuscenes \
    --root-path ./data/nuscenes \
    --canbus ./data/nuscenes \
    --out-dir ./data/infos/ \
    --extra-tag nuscenes \
    --version v1.0
```

### 6. Generate kmeans anchors (once, after info files are ready)
```bash
sh scripts/kmeans.sh
```

### 7. Compile CUDA extensions (once per container build)
```bash
cd projects/mmdet3d_plugin/ops
python3 setup.py develop
cd /workspace/SparseDrive
```

---

## Every Time You Boot the Container

Use the startup script:
```bash
sh start_sparsedrive.sh
```

Then inside the container, compile the CUDA extension if not already done:
```bash
cd projects/mmdet3d_plugin/ops && python3 setup.py develop && cd /workspace/SparseDrive
```

---

## Running Inference and Evaluation

```bash
# Evaluation
sh scripts/test.sh

# Visualization
sh scripts/visualize.sh
```

---

## Folder Structure (What Should Exist Before Running)
```
SparseDrive/
├── ckpt/
│   ├── resnet50-19c8e357.pth
│   ├── sparsedrive_stage1.pth
│   └── sparsedrive_stage2.pth
├── data/
│   ├── nuscenes -> /media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes
│   ├── infos/
│   │   ├── nuscenes_infos_train.pkl
│   │   ├── nuscenes_infos_val.pkl
│   │   └── ...
│   └── kmeans/
├── projects/
└── tools/
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `python: command not found` | Use `python3` instead |
| `deformable_aggregation_ext` import error | Recompile: `cd projects/mmdet3d_plugin/ops && python3 setup.py develop` |
| `permission denied` on docker socket | Use `sudo docker` or add user to docker group: `sudo usermod -aG docker $USER` |
| Symlink broken | Check drive is mounted: `ls /media/ace428/d0868705-3e72-4ad4-b84b-7e73f1dee3e5/nuscenes` |
| Container can't find data | Make sure you're using the correct volume mount paths in start script |