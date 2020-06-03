# Copyright (c) Facebook, Inc. and its affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
#!/bin/bash
# Downloads the data and creates data/all-clean.tgz within the current directory

set -e
set -o pipefail

SRC=en
SI_TGT=si
NE_TGT=ne

ROOT=$(dirname "$0")
DATA=$ROOT/data
BRX_ROOT=$DATA/en-brx
mkdir -p $BRX_ROOT

# Download data
download_data() {
  CORPORA=$1
  URL=$2

  if [ -f $CORPORA ]; then
    echo "$CORPORA already exists, skipping download"
  else
    echo "Downloading $URL"
    wget $URL -O $CORPORA --no-check-certificate || rm -f $CORPORA
    if [ -f $CORPORA ]; then
      echo "$URL successfully downloaded."
    else
      echo "$URL not successfully downloaded."
      rm -f $CORPORA
      exit -1
    fi
  fi
}


# Download parallel en-brx corpus
download_data $DATA/en-brx-health_tourism.tar.gz "http://get.alayaran.com/en-brx-health_tourism.tar.gz"
tar -xvf $DATA/en-brx-health_tourism.tar.gz 
cp -r parallel-data/* $BRX_ROOT
REMOVE_FILE_PATHS+=( parallel-data $DATA/en-brx-health_tourism.tar.gz )


if [ ! -e $MOSES ]; then
    echo "Cloning moses repository..."
    git clone https://github.com/moses-smt/mosesdecoder.git
fi
# Remove the temporary files
for ((i=0;i<${#REMOVE_FILE_PATHS[@]};++i)); do
  rm -rf ${REMOVE_FILE_PATHS[i]}
done

