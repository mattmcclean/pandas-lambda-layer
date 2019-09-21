#!/bin/bash

BUILD_DIR="./build/python"
LAYER_NAME="PandasLayer"
COMPATIBLE_RUNTIMES="python3.7"

#do cleanup of previous zip file
echo "Clean up previous build files"
rm layer.zip
#cleanup previous build artifacts
rm -rf .aws-sam/build/DummyFunction
#clean out the build folder
rm -rf $BUILD_DIR
#make our build folder
mkdir -p $BUILD_DIR
#build the layer
echo "Building new python files in dir: $BUILD_DIR"
sam build --use-container
#copy in the results of the build to our build directory
cp -r .aws-sam/build/DummyFunction/* $BUILD_DIR
# clean up the unnecesary files
pushd $BUILD_DIR
rm -r *.dist-info __pycache__ *.pyc tests
find . -name "tests" -type d -exec rm -rdf {} +
popd
#make our zip file
pushd ./build
echo "Creating zip file: layer.zip"
zip -r9 ../layer.zip .
popd
#clean out the build folder
rm -rf $BUILD_DIR/*
#publish our layer
echo "Publishing new lambda layer with name: ${LAYER_NAME}"
aws lambda publish-layer-version --layer-name ${LAYER_NAME} --zip-file fileb://layer.zip --compatible-runtimes $COMPATIBLE_RUNTIMES