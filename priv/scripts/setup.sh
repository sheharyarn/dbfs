#!/bin/sh

set -e
set -o pipefail
set -o errtrace
set -o errexit


NODE=newyork   mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed
NODE=london    mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed
NODE=singapore mix do ecto.drop, ecto.create, ecto.migrate, ecto.seed


