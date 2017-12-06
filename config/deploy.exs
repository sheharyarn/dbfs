use Bootleg.Config


# Configure the following roles to match your environment.
# `build` defines what remote server your distillery release should be built on.
#
# Some available options are:
#  - `user`: ssh username to use for SSH authentication to the role's hosts
#  - `password`: password to be used for SSH authentication
#  - `identity`: local path to an identity file that will be used for SSH authentication instead of a password
#  - `workspace`: remote file system path to be used for building and deploying this Elixir project

role :build, "dbfs.newyork", workspace: "/tmp/bootleg/build", user: "root", password: "87654321"


# Phoenix has some extra build steps such as asset digesting that need to be done during
# compilation. To have bootleeg handle that for you, include the additional package
# `bootleg_phoenix` to your `deps` list. This will automatically perform the additional steps
# required for building phoenix releases.
#
#  ```
#  # mix.exs
#  def deps do
#    [{:distillery, "~> 1.5"},
#    {:bootleg, "~> 0.6"},
#    {:bootleg_phoenix, "~> 0.2"}]
#  end
#  ```
# For more about `bootleg_phoenix` see: https://github.com/labzero/bootleg_phoenix

