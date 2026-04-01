FROM nvidia/cuda:11.8.0-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git wget curl python3-pip python3-dev \
    libgl1-mesa-glx libglib2.0-0 ninja-build build-essential \
    libgeos-dev libjpeg-dev zlib1g-dev libturbojpeg \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV TORCH_CUDA_ARCH_LIST="8.6"
ENV FORCE_CUDA="1"

RUN pip3 install --upgrade pip
RUN pip3 install setuptools==60.2.0 wheel packaging

# PyTorch — use cu118 instead of cu116, more stable
RUN pip3 install torch==1.13.0+cu116 torchvision==0.14.0+cu116 torchaudio==0.13.0 \
    --extra-index-url https://download.pytorch.org/whl/cu116

# mmcv 1.7.1 from source
RUN git clone https://github.com/open-mmlab/mmcv.git /mmcv && \
    cd /mmcv && \
    git checkout v1.7.1 && \
    MMCV_WITH_OPS=1 FORCE_CUDA=1 TORCH_CUDA_ARCH_LIST="8.6" \
    pip3 install --no-build-isolation . && \
    cd / && rm -rf /mmcv

RUN pip3 install openmim && \
    mim install mmdet==2.28.2 --no-build-isolation && \
    mim install mmsegmentation==0.30.0 --no-build-isolation && \
    pip3 install mmdet3d==1.0.0rc6 --no-deps --no-build-isolation

# requirements.txt dependencies minus flash-attn (handle separately)
RUN pip3 install \
    numpy==1.23.5 \
    urllib3==1.26.16 \
    pyquaternion==0.9.9 \
    nuscenes-devkit==1.1.10 \
    yapf==0.33.0 \
    tensorboard==2.14.0 \
    motmetrics==1.1.3 \
    pandas==1.1.5 \
    opencv-python==4.8.1.78 \
    prettytable==3.7.0 \
    scikit-learn==1.3.0

# flash-attn — build separately, this takes a while
RUN pip3 install flash-attn==2.3.2 --no-build-isolation

WORKDIR /workspace/SparseDrive