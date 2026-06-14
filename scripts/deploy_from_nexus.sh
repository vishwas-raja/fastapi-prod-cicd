#!/bin/bash
set -e

APP_NAME="fastapi-prod-cicd"
APP_DIR="/opt/$APP_NAME"
ARTIFACT_NAME="app.tar.gz"

NEXUS_ARTIFACT_URL="$1"
NEXUS_USER="$2"
NEXUS_PASSWORD="$3"

echo "Downloading artifact from Nexus..."

mkdir -p /tmp/$APP_NAME

curl -u "$NEXUS_USER:$NEXUS_PASSWORD" \
  -o /tmp/$APP_NAME/$ARTIFACT_NAME \
  "$NEXUS_ARTIFACT_URL"

echo "Extracting artifact..."

rm -rf $APP_DIR/current
mkdir -p $APP_DIR/current

tar -xzf /tmp/$APP_NAME/$ARTIFACT_NAME -C $APP_DIR/current --strip-components=1

cd $APP_DIR/current

echo "Creating Python virtual environment..."

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

echo "Restarting app service..."

sudo systemctl restart fastapi-prod-cicd

echo "Deployment completed from Nexus."
