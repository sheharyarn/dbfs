#!/bin/sh

set -e
set -o pipefail
set -o errtrace
set -o errexit


NODE=newyork   PRIMARY=1 SEED_BLOCKS=1 mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed
NODE=london    PRIMARY=0 SEED_BLOCKS=0 mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed
NODE=singapore PRIMARY=0 SEED_BLOCKS=0 mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed


