FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04


ARG DEBIAN_FRONTEND=noninteractive

# ENV is available both during build-time and at runtime. 
#To save you a headache,Avoids locale issues when running Python inside Docker.
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

#Ensures CUDA libraries are properly recognized.
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
ENV PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Fix Nvidia/Cuda repository key rotation
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list.d/*
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/machine-learning\/repos/d' /etc/apt/sources.list.d/*
RUN apt-key del 7fa2af80 &&\
	apt-get update && \
	apt-get  install -y wget && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb

# CV2 Deps,Required for computer vision tasks using OpenCV since opencv-python(in pyproject.toml) from PyPI does not include system-level dependencies. 
RUN apt-get install -y ffmpeg libsm6 libxext6 libgl1

RUN apt update && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y curl bzip2


ENV CONDA_DIR=/opt/conda
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-py310_24.1.2-0-Linux-x86_64.sh && \
    bash Miniconda3-py310_24.1.2-0-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-py310_24.1.2-0-Linux-x86_64.sh
# Add conda to PATH
ENV PATH=$CONDA_DIR/bin:$PATH
# Verify conda installation
RUN conda --version


# Declare build-time variable with a default value of 1000.
ARG UID=1000
ARG GID=1000
# Create a group inside the container with the specified GID.
RUN groupadd -g $GID appgroup && \
    useradd -u $UID -g $GID -m appuser
# Optionally switch to the user
USER appuser


# Create working directory
WORKDIR /diffusion_policy

