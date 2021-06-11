ARG TAG="21.05-py3"
FROM nvcr.io/nvidia/pytorch:$TAG

ENV DATASETS_DIR=/var/datasets
ENV LIB_DIR=/opt

# Install basics.
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
 && apt-get install -y neovim parallel tmux unzip wget

# Download datasets.
ENV COCO_DATASETS_DIR=$DATASETS_DIR/coco
WORKDIR $COCO_DATASETS_DIR

ARG COCO_DATASETS="http://images.cocodataset.org/zips/val2017.zip \
 http://images.cocodataset.org/annotations/annotations_trainval2017.zip"

RUN parallel --will-cite --jobs 0 'wget -nv -nc {}; unzip -q -n $(basename {})' ::: $COCO_DATASETS

# Install Detectron2.
WORKDIR $LIB_DIR

ENV DETECTRON2_DATASETS=$DATASETS_DIR
RUN git clone https://github.com/facebookresearch/detectron2.git \
 && python -m pip install -e detectron2

# Install Torch2TRT.
WORKDIR $LIB_DIR

RUN git clone https://github.com/chaoz-dev/torch2trt.git \
 && python -m pip install -e torch2trt

# Install CenterMask2.
ENV CENTERMASK2_DIR=$LIB_DIR/centermask2
ADD . $CENTERMASK2_DIR

WORKDIR $CENTERMASK2_DIR

ARG VOVNET2_MODELS="https://dl.dropbox.com/s/tczecsdxt10uai5/centermask2-V-39-eSE-FPN-ms-3x.pth \
 https://dl.dropbox.com/s/zmps03vghzirk7v/centermask-V-39-eSE-dcn-FPN-ms-3x.pth     \
 https://dl.dropbox.com/s/lw8nxajv1tim8gr/centermask2-V-57-eSE-FPN-ms-3x.pth        \
 https://dl.dropbox.com/s/1f64azqyd2ot6qq/centermask-V-57-eSE-dcn-FPN-ms-3x.pth     \
 https://dl.dropbox.com/s/c6n79x83xkdowqc/centermask2-V-99-eSE-FPN-ms-3x.pth        \
 https://dl.dropbox.com/s/atuph90nzm7s8x8/centermask-V-99-eSE-dcn-FPN-ms-3x.pth"

RUN parallel --will-cite --jobs 0 'wget -nv -nc {}' ::: $VOVNET2_MODELS
