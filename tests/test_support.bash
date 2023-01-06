bats_load_library bats-support
bats_load_library bats-assert
bats_require_minimum_version 1.5.0

# setup_file() function run once for a given bats test file.
setup_file() {
  set -x

  if [ -z "$FLOX_CLI" ]; then
    if [ -L ./result ]; then
      FLOX_PACKAGE=$(readlink ./result)
    else
      FLOX_PACKAGE=$(flox build -A flox --print-out-paths --substituters "")
    fi
    export FLOX_PACKAGE
    export FLOX_CLI=$FLOX_PACKAGE/bin/flox
  fi
  export TEST_ENVIRONMENT=_testing_
  export NIX_SYSTEM=$($FLOX_CLI nix --extra-experimental-features nix-command show-config | awk '/system = / {print $NF}')
  # Simulate pure bootstrapping environment. It is challenging to get
  # the nix, gh, and flox tools to all use the same set of defaults.
  export REAL_XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
  export FLOX_TEST_HOME=$(mktemp -d)
  export XDG_CACHE_HOME=$FLOX_TEST_HOME/.cache
  export XDG_DATA_HOME=$FLOX_TEST_HOME/.local/share
  export XDG_CONFIG_HOME=$FLOX_TEST_HOME/.config
  export FLOX_CACHE_HOME=$XDG_CACHE_HOME/flox
  export FLOX_META=$FLOX_CACHE_HOME/meta
  export FLOX_DATA_HOME=$XDG_DATA_HOME/flox
  export FLOX_ENVIRONMENTS=$FLOX_DATA_HOME/environments
  export FLOX_CONFIG_HOME=$XDG_CONFIG_HOME/flox
  # Weirdest thing, gh will *move* your gh creds to the XDG_CONFIG_HOME
  # if it finds them in your home directory. Doesn't ask permission, just
  # does it. That is *so* not the right thing to do. (visible with strace)
  # 1121700 renameat(AT_FDCWD, "/home/brantley/.config/gh", AT_FDCWD, "/tmp/nix-shell.dtE4l4/tmp.JD4ki0ZezY/.config/gh") = 0
  # The way to defeat this behavior is by defining GH_CONFIG_DIR.
  export REAL_GH_CONFIG_DIR=$REAL_XDG_CONFIG_HOME/gh
  export GH_CONFIG_DIR=$XDG_CONFIG_HOME/gh
  # Don't let ssh authentication confuse things.
  # Remove any vestiges of previous test runs.
  XDG_CONFIG_HOME=$REAL_XDG_CONFIG_HOME GH_CONFIG_DIR=$REAL_GH_CONFIG_DIR \
    $FLOX_CLI destroy -e $TEST_ENVIRONMENT --origin -f || :
  rm -f tests/out/foo tests/out/subdir/bla
  rmdir tests/out/subdir tests/out || :
  rm -f $FLOX_CONFIG_HOME/{gitconfig,nix.conf}
  set +x
}