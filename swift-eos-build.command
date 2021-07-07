
#!/bin/bash

#set -x
set -e
set -u
set -o pipefail

export LANG=C.UTF-8

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

"$SCRIPT_DIR/Scripts/build-clang-module.sh"
"$SCRIPT_DIR/Scripts/dump-eos-sdk-ast.sh"
swift run swift-eos-build "$@"
