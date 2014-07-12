cluster
=======

Bootstrap Cluster for MPI

## Requirements

- Vagrant
- Docker
- VirtualBox
- ruby, bundler
- pdsh

## Setup

```
$ bundle install --path vendor/bundle --binstubs .bundle/bin
$ export PATH=$PATH:./.bundle/bin
$ cluster init
```

## Usage

```
$ cluster up
$ vagrant ssh mpi0
$ cp -r /usr/local/mpispec/sample /data/
$ cd /data/sample
$ mpispec -np 3 --allow-run-as-root --hostfile /data/hostfile
```

```
$ cluster halt
```
