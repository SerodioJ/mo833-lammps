#!/bin/bash

function fail() {
  echo "ERROR: $@"
  exit 1
}

# Run command inside docker at directory $(pwd)/bench
docker run --rm --user=$(id -u):$(id -g) -v $(pwd):$(pwd) -w $(pwd)/bench ubuntu:mpi-dev \
	mpirun -np 2 -host localhost,localhost ../build/lmp -in in.spce 1> in.spce.results.N.2.stdout 2> in.spce.results.N.2.stderr || \
	fail "Error when executing LAMMPS"
	
