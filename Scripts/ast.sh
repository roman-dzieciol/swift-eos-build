
set -e
set -o pipefail

export INPUT_DIR="/Users/rd/_ue/SwiftEOS/EOS/EOSSDK.xcframework/ios-arm64/EOSSDK.framework/Headers"
export CLANG_ARGS=" -femit-all-decls -Xpreprocessor -femit-all-decls -Xclang -femit-all-decls -Xpreprocessor -CC -Xpreprocessor -C -Xpreprocessor -dD  -Xclang -fno-eliminate-unused-debug-types -std=gnu11 -fparse-all-comments --verbose -F/Users/rd/_ue/SwiftEOS/EOS/EOSSDK.xcframework/ios-arm64/"
clang -E -C -CC -dD --no-line-commands $CLANG_ARGS $INPUT_DIR/eos_all.h > /Users/rd/_ue/SwiftEOS/eos_all.h
clang -E -dD --no-line-commands $CLANG_ARGS $INPUT_DIR/eos_all.h > /Users/rd/_ue/SwiftEOS/eos_all_nc.h
clang -Xclang -ast-dump=json $CLANG_ARGS eos_all.h > /Users/rd/_ue/SwiftEOS/EOSSDK.ast.json
clang -Xclang -ast-dump -fno-color-diagnostics $CLANG_ARGS eos_all.h > /Users/rd/_ue/SwiftEOS/EOSSDK.ast.txt
