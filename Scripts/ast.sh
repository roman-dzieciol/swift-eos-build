
set -e
set -o pipefail

export XCFW_DIR="../../EOSSDK.xcframework/"
export FW_DIR="$XCFW_DIR/ios-arm64/EOSSDK.framework/"
export HEADERS_DIR="$FW_DIR/Headers"
export TEMP_DIR="../Temp/"
export CLANG_ARGS=" -femit-all-decls -Xpreprocessor -femit-all-decls -Xclang -femit-all-decls -Xpreprocessor -CC -Xpreprocessor -C -Xpreprocessor -dD  -Xclang -fno-eliminate-unused-debug-types -std=gnu11 -fparse-all-comments --verbose -F$XCFW_DIR/ios-arm64/"
clang -E -C -CC -dD --no-line-commands $CLANG_ARGS $HEADERS_DIR/eos_all_ios.h > $TEMP_DIR/eos_all.h
clang -E -dD --no-line-commands $CLANG_ARGS $HEADERS_DIR/eos_all_ios.h > $TEMP_DIR/eos_all_nc.h
clang -Xclang -ast-dump=json $CLANG_ARGS $TEMP_DIR/eos_all.h > $TEMP_DIR/EOSSDK.ast.json
clang -Xclang -ast-dump -fno-color-diagnostics $CLANG_ARGS $TEMP_DIR/eos_all.h > $TEMP_DIR/EOSSDK.ast.txt
