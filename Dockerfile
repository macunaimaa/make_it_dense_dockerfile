FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04  # Use a CUDA-enabled base image

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

RUN apt update && \
    apt install -y build-essential \
                   cmake \
                   git \
                   libblosc-dev \
                   libboost-all-dev \
                   libgl1 \
                   libtbb-dev \
                   python3-pip \
                   pybind11-dev

# Install CUDA Toolkit dependencies
RUN apt-get install -y --no-install-recommends \
    cuda-command-line-tools-11-8 \
    cuda-libraries-dev-11-8 \
    libcublas-dev-11-8 \
    libcudnn8-dev

RUN pip install numpy && \
    git clone https://github.com/nachovizzo/openvdb.git -b nacho/fix_background_inactive && \
    cd openvdb && \
    mkdir build && cd build && \
    cmake \
    -DOPENVDB_BUILD_PYTHON_MODULE=ON \
    -DUSE_NUMPY=ON \
    .. && \
    make -j2 all install

RUN git clone --recursive https://github.com/PRBonn/vdb_to_numpy && \
    cd vdb_to_numpy && \
    pip install .

RUN git clone https://github.com/PRBonn/vdbfusion.git && \
    cd vdbfusion && \
    sed -i 's/"-c"/"-I" "-c"/g' src/vdbfusion/pybind/CMakeLists.txt && \
    pip install . && \
    pip install Cython==0.29.36 && \
    cd .. && \
    git clone https://github.com/yaml/pyyaml.git && \
    cd pyyaml && \
    git checkout release/5.4.1 && \
    sed -i.bak 's/Cython/Cython<3.0/g' pyproject.toml && \
    python3 setup.py sdist && \
    pip install --pre dist/PyYAML-5.4.1.tar.gz && \
    cd .. && \
    git clone https://github.com/PRBonn/make_it_dense && \
    cd make_it_dense && \
    pip install .

COPY /pointcloud.pcd ../pointcloud.pcd

RUN cd make_it_dense/apps && \
    sed -i 's/python/python3/g' test_scan.py