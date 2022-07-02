FROM ubuntu:20.04 as build_stage

WORKDIR /lammps

# Update Ubuntu reporitories and install download tool
RUN apt update && \
    apt install -y build-essential wget git && \
    DEBIAN_FRONTEND=noninteractive apt install -y git openmpi-common openmpi-bin libopenmpi-dev cmake

# Copy source code
COPY . .

# Build PI intrumentation lib
RUN cd utils && \
    make

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

# Copy LAMMPS executable from build stage
COPY --from=build_stage /lammps/build/lmp .

# Add lammps executable to PATH
ENV PATH=$PATH:/lammps
