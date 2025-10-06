#!/bin/bash

# load.bash - Main load helper for BATS tests
# This file loads bats-support and bats-assert, sets strict shell options, and configures PATH

# Get the directory of this script
HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HELPERS_DIR/../.." && pwd)"

# Add test/bin to PATH for shims
export PATH="$REPO_ROOT/test/bin:$PATH"

# Add bats-core bin to PATH if needed
export PATH="$REPO_ROOT/test/vendor/bats-core/bin:$PATH"

# Load bats-support and bats-assert
load "$REPO_ROOT/test/vendor/bats-support/load"
load "$REPO_ROOT/test/vendor/bats-assert/load"

# Set strict bash options for tests
set -euo pipefail

# Set timezone for deterministic tests
export TZ=UTC

# Common test variables
export REPO_ROOT
export HELPERS_DIR

# Source additional helpers
source "$HELPERS_DIR/env.bash"
source "$HELPERS_DIR/git.bash" 
source "$HELPERS_DIR/asserts.bash"