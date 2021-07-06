# SwiftEOSBuild

Automatic Swift bindings for Epic Online Services framework.

This tool takes the C language EOSSDK.framework as input and generates object oriented Swift bindings for the C SDK.

The Swift API uses only Swift types. All pointers required by the C SDK are managed internally.

## Tools

### ./Script/build-clang-module.sh

Patches the C EOSSDK.framework so that it can be imported into Swift projects

### ./Script/dump-eossdk-ast.sh

Outputs clang AST of the EOS SDK, including comment nodes, for use by SwiftEOSBuild

### SwiftEOSBuild

Outputs Swift API for EOS SDK, including all neccesary memory management code

## Inputs

By default, scripts expect the official EOS SDK to be placed in `../SDK/<EOS Version>/EOSSDK.framework` folder, relative to the repository.

## Outputs

- EOS.framework
 - Object oriented Swift bindings API for the EOSSDK.framework
 - All pointers required by C framework are managed internally
 - Depends on EOSSDK.framework

- ./Temp/<EOS Version>/EOSSDK.framework
 - A patched version of the official SDK, includes a Swift modulemap and tweaks to headers so that the framework can be imported into Swift projects
  
- ./Temp/<EOS Version>/EOSSDK.xcframework
 - The modified framework packaged as xcframework for Swift Package Manager compatibility
  
- ./Temp/AST
 - C EOSSDK AST in Clang JSON format, including comment nodes, for internal use by the tooling

