# SwiftEOSBuild

Swift bindings generator for Epic Online Services framework.

This tool takes the C language EOSSDK.framework as input and generates object oriented Swift bindings for the C SDK.

The Swift API uses only Swift types. All pointers required by the C SDK are managed internally.

The autogenerated bindings can be found here: https://github.com/roman-dzieciol/swift-eos

# Step by step instructions

First, Download the iOS version of EOS SDK from https://dev.epicgames.com/portal/

Place the contents of the archive parallel to this source code repository, ie:
- `/Users/username/repositories/EOS-SDK-IOS-16697186-v1/SDK/Bin/IOS/EOSSDK.framework`
- `/Users/username/repositories/swift-eos-build/`

Then, edit `eos-version.txt` if needed so that it contains the version/name of the folder above, ie `EOS-SDK-IOS-16697186-v1`

There are two ways you can launch it:

## 1) (Recommended) Launch with Xcode

This will allow you to debug and see all the log messages. You will need to perform some setup manually.

1) Launch `./Scripts/build-clang-module` to create a patched version of the SDK
1) Launch `./Scripts/dump-eossdk-ast.sh` to get the AST of SDK headers
1) Open `Package.swift` in Xcode, change the scheme to `swift-eos-build`, and device to `MacOS`
1) Run the scheme to compile and launch the tool

The script steps are needed only once for each version of SDK.

## 2) (Simple) Launch from commandline or Finder

This will perform the two steps above, then compile and launch the tool.

1) Launch `swift-eos-build.command` from commandline or Finder

To see the debug logs from commandline output, open `Console.app` before launching then search or filter for subsystem `dev.roman.eos`

I recommend launching from Xcode as this is still under development.

## Output

The bindings will be in `./Temp/EOS-SDK-IOS-16697186-v1/Bindings` subdirectory of the repo. 

You can use them as Swift package, or copy them all (or some) to your project.

## Relaunching

By default nothing will be overwritten, so if you try to launch it again you'll get an error.

To move automatically the generated output to trash, add `--allow-delete` to Xcode scheme's arguments, or to the `swift-eos-build.sh` commandline.

# Tools

## `./Scripts/build-clang-module`

Patches the C EOSSDK.framework so that it can be imported into Swift projects

## `./Scripts/dump-eossdk-ast.sh`

Outputs clang AST of the EOS SDK, including comment nodes, for use by SwiftEOSBuild

## `SwiftEOSBuild`

Outputs Swift API for EOS SDK, including all neccesary memory management code

# Inputs

By default, scripts expect the official EOS SDK to be placed in `../SDK/<EOS Version>/EOSSDK.framework` folder, relative to the repository.

# Outputs

## `Temp/<EOS Version>/Bindings/EOS`
  - Object oriented Swift bindings API for the EOSSDK.framework
  - All pointers required by C framework are managed internally
  - Depends on EOSSDK.framework

## `./Temp/<EOS Version>/EOSSDK.framework`
  - A patched version of the official SDK, includes a Swift modulemap and tweaks to headers so that the framework can be imported into Swift projects
  
## `./Temp/<EOS Version>/EOSSDK.xcframework`
  - The modified framework packaged as xcframework for Swift Package Manager compatibility
  
## `./Temp/AST`
  - C EOS SDK AST in Clang JSON format, including comment nodes, for internal use by the tooling

