#!/bin/bash
if [ ! -e $(dirname "$0")/.env ]; then
  echo ".env not found, cannot upload files!"
  echo "Please create .env with UPLOAD_USER, UPLOAD_HOST and UPLOAD_PATH if you would like to upload files."
fi

source $(dirname "$0")/.env

(cd ../..;
for package in iota-bee iota-goshimmer; do
  echo "Building and uploading '$package'..."
 
  # build
  (cd $(dirname "$0")/$package/tools; ./build.sh)

  # upload
  if [ -e $(dirname "$0")/common/tools/.env ]; then
    packagePath=$(dirname "$0")/$package/build/install.tar.gz
    if [ -f "$packagePath" ]; then
      scp "$packagePath" $UPLOAD_USER@$UPLOAD_HOST:$UPLOAD_PATH/$package
    fi
  fi
  echo "--------------------------------------------------------------------------------"
done
)
