# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Continue with the rest of your Dockerfile instructions...

# Install OpenVDB dependencies
RUN apt-get update && apt-get install -y \
    libblosc-dev \
    libboost-iostreams-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libopenexr-dev \
    libtbb2

# Clone and install OpenVDB (using the specific fork mentioned)
RUN git clone https://github.com/nachovizzo/openvdb.git -b nacho/fix_background_inactive \
    && cd openvdb \
    && mkdir build && cd build \
    && cmake -DOPENVDB_BUILD_PYTHON_MODULE=ON -DUSE_NUMPY=ON .. \
    && make -j$(nproc) all install

# Placeholder for copying a file from your host to the container
# Replace 'path/to/your/local/file' with the actual path to the file on your host machine
# The destination is the 'make_it_dense' folder within the container
COPY /pointcloud.pcd /make_it_dense

# Install Python dependencies
RUN pip3 install numpy

# Clone and install vdb_to_numpy
RUN git clone https://github.com/PRBonn/vdb_to_numpy \
    && cd vdb_to_numpy \
    && pip3 install .

# Clone and install vdbfusion
RUN git clone https://github.com/PRBonn/vdbfusion.git \
    && cd vdbfusion \
    && pip3 install .

# Set the working directory
WORKDIR /make_it_dense

# Clone the make_it_dense repository
RUN git clone https://github.com/PRBonn/make_it_dense.git .

# Install make_it_dense
RUN pip3 install .

# Install PyTorch with CUDA support (adjust the version as needed)
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

# Command to run when starting the container
CMD ["/bin/bash"]
