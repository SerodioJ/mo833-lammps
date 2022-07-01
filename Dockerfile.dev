FROM ubuntu:20.04
LABEL maintainer="edson@ic.unicamp.br"
LABEL version="1.0"
# Update Ubuntu reporitories and install download tool
RUN apt update && \
    apt install -y build-essential wget git && \
    DEBIAN_FRONTEND=noninteractive apt install -y git openmpi-common openmpi-bin libopenmpi-dev cmake
     


#ENV PATH=$PATH:/usr/local/gromacs/bin
# Uncomment bellow to use the dockerfile as a GROMACS binary
#ENTRYPOINT [ "/usr/local/gromacs/bin/gmx" ]

