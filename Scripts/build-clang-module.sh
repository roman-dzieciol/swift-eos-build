#!/bin/bash

#set -x
set -e
set -u
set -o pipefail

export LANG=C.UTF-8

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export EOS_IOS_VERSION=$(cat "$SCRIPT_DIR/../eos-version.txt" | tr -d '[:space:]')
export EOS_MACOS_VERSION=$(cat "$SCRIPT_DIR/../eos-version.macos.txt" | tr -d '[:space:]')
export EOS_FW_SUB_DIR="SDK/Bin/IOS"
export EOS_FW_NAME="EOSSDK.framework"
export EOS_XCFW_NAME="EOSSDK.xcframework"

export EOS_MACOS_DYLIB_PATH="$SCRIPT_DIR/../../$EOS_MACOS_VERSION/SDK/Bin/libEOSSDK-Mac-Shipping.dylib"

export TEMPLATE_DIR="$SCRIPT_DIR/../Template"
export TEMPLATE_FW_MACOS_X86_64_DIR="$TEMPLATE_DIR/macos-x86_64/EOSSDK.framework"

export FW_PATH="$EOS_IOS_VERSION/$EOS_FW_SUB_DIR/$EOS_FW_NAME"
export FW_DIR="$SCRIPT_DIR/../../$FW_PATH"
export HEADERS_DIR="$FW_DIR/Headers"
export OUTPUT_DIR="$SCRIPT_DIR/../Temp"
export OUTPUT_FW_IOS_ARM64_DIR="$OUTPUT_DIR/$EOS_IOS_VERSION/ios-arm64/$EOS_FW_NAME"
export OUTPUT_FW_MACOS_X86_64_DIR="$OUTPUT_DIR/$EOS_MACOS_VERSION/macos-x86_64/$EOS_FW_NAME"
export OUTPUT_XCFW_DIR="$OUTPUT_DIR/$EOS_IOS_VERSION/$EOS_XCFW_NAME"

# copy ios-arm64 framework to output directory
if [[ -d "$OUTPUT_FW_IOS_ARM64_DIR" ]]; then
  rm -r "$OUTPUT_FW_IOS_ARM64_DIR"
fi
if [[ ! -d "$OUTPUT_FW_IOS_ARM64_DIR" ]]; then
  mkdir -p "$OUTPUT_FW_IOS_ARM64_DIR"
fi
cp -R "$FW_DIR/" "$OUTPUT_FW_IOS_ARM64_DIR"

# use framework includes 
grep -lr "#include " "$OUTPUT_FW_IOS_ARM64_DIR/Headers" | xargs sed -i '' -E "s|#include \"(.*).h\"|#include <EOSSDK/\1.h>|gi"
#grep -lr "#include " "$OUTPUT_FW_IOS_ARM64_DIR/Headers" | xargs sed -i '' -E "s|#include \"(.*).inl\"|#include <EOSSDK/\1.h>|gi"

# add umbrella header
echo "#pragma once" > "$OUTPUT_FW_IOS_ARM64_DIR/Headers/eos_umbrella.h"
find "$OUTPUT_FW_IOS_ARM64_DIR/Headers" -type f -name "*.h" -print | xargs -n1 basename | sort | sed -E "s|(.*).h|#include <EOSSDK/\1.h>|gi" >> "$OUTPUT_FW_IOS_ARM64_DIR/Headers/eos_umbrella.h"
#find "$OUTPUT_FW_IOS_ARM64_DIR/Headers" -type f -name "*.inl" -print | xargs -n1 basename | sort | sed -E "s|(.*).inl|#include <EOSSDK/\1.h>|gi" >> "$OUTPUT_FW_IOS_ARM64_DIR/Headers/eos_umbrella.h"
#find "$OUTPUT_FW_IOS_ARM64_DIR/Headers" -type f -name "*.inl" -exec sh -c 'mv "$1" "${1%.inl}.h"' _ {} \;

# remove textual headers from umbrella header
sed -i '' -E "s|#include <EOSSDK/eos_result.h>||gi" "$OUTPUT_FW_IOS_ARM64_DIR/Headers/eos_umbrella.h"
sed -i '' -E "s|#include <EOSSDK/eos_ui_keys.h>||gi" "$OUTPUT_FW_IOS_ARM64_DIR/Headers/eos_umbrella.h"

# fix comments
grep -lr "// " "$OUTPUT_FW_IOS_ARM64_DIR/Headers" | xargs sed -i '' -E "s|// (.*)|/** \1 */|gi"

# add module map
if [[ ! -d "$OUTPUT_FW_IOS_ARM64_DIR/Modules" ]]; then
  mkdir -p "$OUTPUT_FW_IOS_ARM64_DIR/Modules"
fi
cp -R "$SCRIPT_DIR/EOSSDK_Modules/" "$OUTPUT_FW_IOS_ARM64_DIR/Modules"

ls "$OUTPUT_FW_IOS_ARM64_DIR/"


# copy macos-x86_64 template to output directory
if [[ -d "$OUTPUT_FW_MACOS_X86_64_DIR" ]]; then
  rm -r "$OUTPUT_FW_MACOS_X86_64_DIR"
fi
if [[ ! -d "$OUTPUT_FW_MACOS_X86_64_DIR" ]]; then
  mkdir -p "$OUTPUT_FW_MACOS_X86_64_DIR"
fi
cp -R "$TEMPLATE_FW_MACOS_X86_64_DIR/" "$OUTPUT_FW_MACOS_X86_64_DIR"

# rewrite macos-x86_64 dylib into output directory
lipo -create "$EOS_MACOS_DYLIB_PATH" -output "$OUTPUT_FW_MACOS_X86_64_DIR/Versions/A/EOSSDK"

# update rpath for macos-x86_64 
install_name_tool -id @rpath/EOSSDK.framework/Versions/A/EOSSDK "$OUTPUT_FW_MACOS_X86_64_DIR/Versions/A/EOSSDK"

# copy headers for macos-x86_64
cp -R "$OUTPUT_FW_IOS_ARM64_DIR/Headers/" "$OUTPUT_FW_MACOS_X86_64_DIR/Versions/A/Headers"

# copy modulemap for macos-x86_64 
cp -R "$SCRIPT_DIR/EOSSDK_Modules/module.modulemap" "$OUTPUT_FW_MACOS_X86_64_DIR/Versions/A/Modules/"

# output xcframework
if [[ -d "$OUTPUT_XCFW_DIR" ]]; then
  rm -r "$OUTPUT_XCFW_DIR"
fi
if [[ ! -d "$OUTPUT_XCFW_DIR" ]]; then
  mkdir -p "$OUTPUT_XCFW_DIR"
fi
xcrun xcodebuild -create-xcframework -framework "$OUTPUT_FW_IOS_ARM64_DIR" -framework "$OUTPUT_FW_MACOS_X86_64_DIR" -output "$OUTPUT_XCFW_DIR" -allow-internal-distribution

# copy xcframework to local sample
export SAMPLE_SDK_DIR="$SCRIPT_DIR/../Sample/Local"
export SAMPLE_SDK_XCFW_DIR="$SAMPLE_SDK_DIR/SDK"
if [[ -d "$SAMPLE_SDK_XCFW_DIR" ]]; then
  rm -r "$SAMPLE_SDK_XCFW_DIR"
fi
if [[ ! -d "$SAMPLE_SDK_XCFW_DIR" ]]; then
  mkdir -p "$SAMPLE_SDK_XCFW_DIR"
fi
cp -R "$OUTPUT_XCFW_DIR" "$SAMPLE_SDK_XCFW_DIR"

# test compilation of a package with xcframework as local dependency
cd "$SAMPLE_SDK_DIR"
xcrun xcodebuild -scheme Local -quiet -sdk iphoneos -destination generic/platform=iOS clean build
