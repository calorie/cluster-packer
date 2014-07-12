cluster
=======

Bootstrap Cluster for MPI

## Requirements

- [Vagrant](http://www.vagrantup.com)
- [Docker](http://www.docker.com)
- [VirtualBox](https://www.virtualbox.org)
- [Packer](http://www.packer.io)
- [Ruby](https://www.ruby-lang.org), [Bundler](http://bundler.io)
- [pdsh](https://code.google.com/p/pdsh)

## Setup

```
$ bundle install --path vendor/bundle --binstubs .bundle/bin
$ export PATH=$PATH:./.bundle/bin
$ cluster init
```

## Usage

```
$ cluster up
$ cluster deploy -s
$ cluster halt
```
