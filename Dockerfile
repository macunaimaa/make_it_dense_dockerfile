# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    python3-pip \
    python3-dev \
    libboost-all-dev \
    libtbb-dev \
    libopenblas-dev \
    libglfw3-dev \
    libglew-dev \
    wget \
    xorg \
    libblosc-dev \
    libboost-iostreams-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libopenexr-dev \
    libtbb2 \
    libjemalloc-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies including numpy and pybind11
RUN pip3 install numpy pybind11

# Clone and install OpenVDB (using the specific fork mentioned)
# Reduce parallelism by limiting make to use only 2 jobs
RUN git clone https://github.com/nachovizzo/openvdb.git -b nacho/fix_background_inactive \
    && cd openvdb \
    && mkdir build && cd build \
    && cmake -DOPENVDB_BUILD_PYTHON_MODULE=ON -DUSE_NUMPY=ON -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) .. \
    && make -j2 all install

# Placeholder for copying a file from your host to the container
COPY /pointcloud.pcd /make_it_dense/pointcloud.pcd

# Clone and install vdb_to_numpy
RUN git clone https://github.com/PRBonn/vdb_to_numpy \
    && cd vdb_to_numpy \
    && git submodule update --init --recursive \
    && pip3 install .

# Clone and install vdbfusion
RUN git clone https://github.com/PRBonn/vdbfusion.git \
    && cd vdbfusion \
    && pip3 install .

# Before setting WORKDIR, clone the make_it_dense repository
RUN git clone https://github.com/PRBonn/make_it_dense.git /temp_make_it_dense

# Set the working directory
WORKDIR /make_it_dense

# Move the cloned repository into the working directory
RUN mv /temp_make_it_dense/* /make_it_dense/ && \
    rm -rf /temp_make_it_dense

# Continue with the installation of make_it_dense
RUN pip3 install .


# Install PyTorch with CUDA support (adjust the version as needed)
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

# Command to run when starting the container
CMD ["/bin/bash"]
