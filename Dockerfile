FROM ubuntu:20.04 as base_stage

WORKDIR /lammps

# Update Ubuntu reporitories and install download tool
RUN apt update && \
    apt install -y build-essential wget git && \
    DEBIAN_FRONTEND=noninteractive apt install -y git openmpi-common openmpi-bin libopenmpi-dev cmake

# Copy source code
COPY src src
COPY cmake cmake

FROM base_stage as proxy_build

COPY utils /lammps/utils

# Build PI intrumentation lib
RUN cd utils && \
    make

RUN cp utils/proxy_code/src/* src/ && \
    cp utils/proxy_code/cmake/* cmake/

# Build Proxy
RUN mkdir build && \
    cd build && \
    cmake ../cmake/ -DCMAKE_BUILD_TYPE=Release  -DPKG_KSPACE=on -DPKG_MANYBODY=on -DPKG_RIGID=on -DPKG_MISC=on -DPKG_MOLECULE=on -DBUILD_MPI=on -DPKG_GRANULAR=on -DMPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpic++ -DBUILD_OMP=on && \
    make -j 4

FROM base_stage as lammps_build

# Build LAMMPS
RUN mkdir build && \
    cd build && \
    cmake ../cmake/ -DCMAKE_BUILD_TYPE=Release  -DPKG_KSPACE=on -DPKG_MANYBODY=on -DPKG_RIGID=on -DPKG_MISC=on -DPKG_MOLECULE=on -DBUILD_MPI=on -DPKG_GRANULAR=on -DMPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpic++ -DBUILD_OMP=on && \
    make -j 4

FROM ubuntu:20.04
LABEL maintainer="joaoserodio@live.com"
LABEL version="1.0"

WORKDIR /lammps

# Install required libs to LAMMPS execution
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends libgomp1 openmpi-bin && \
    rm -rf /var/lib/apt/lists/*

# Copy LAMMPS and Proxy executables from build stages
COPY --from=lammps_build /lammps/build/lmp lmp
COPY --from=proxy_build /lammps/build/lmp proxy_lmp

# Add lammps executable to PATH
ENV PATH=$PATH:/lammps
