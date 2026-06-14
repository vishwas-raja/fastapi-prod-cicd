#!/bin/bash
set -e

APP_NAME="fastapi-prod-cicd"
BUILD_DIR="build"
ARTIFACT_NAME="app.tar.gz"

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR/$APP_NAME

cp -r app $BUILD_DIR/$APP_NAME/
cp app/requirements.txt $BUILD_DIR/$APP_NAME/
cp -r nginx $BUILD_DIR/$APP_NAME/
cp docker-compose.yml $BUILD_DIR/$APP_NAME/ 2>/dev/null || true

cd $BUILD_DIR
tar -czf $ARTIFACT_NAME $APP_NAME

echo "Artifact created: $BUILD_DIR/$ARTIFACT_NAME"
