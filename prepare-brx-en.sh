# Copyright (c) Facebook, Inc. and its affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
#!/bin/bash

SRC=brx
TGT=en
DOM1=tourism
DOM2=health
BPESIZE=10000
TRAIN_MINLEN=1  # remove sentences with <1 BPE token
TRAIN_MAXLEN=250  # remove sentences with >250 BPE tokens
DATA_DIR="en-brx"
ROOT=$(dirname "$0")
SCRIPTS=$ROOT/scripts
DATA=$ROOT/data
TMP=$DATA/${SRC}_${TGT}_bpe${BPESIZE}
DATABIN=$ROOT/data-bin/${SRC}_${TGT}_bpe${BPESIZE}
mkdir -p $TMP $DATABIN

SRC_TOKENIZER="bash $SCRIPTS/indic_norm_tok.sh $SRC"
TGT_TOKENIZER="cat"  # learn target-side BPE over untokenized (raw) text
SPM_TRAIN=$SCRIPTS/spm_train.py
SPM_ENCODE=$SCRIPTS/spm_encode.py

URLS=(
    "http://get.alayaran.com/"
)
ARCHIVES=(
    "en-brx-health_tourism.tar.gz"
)
TRAIN_SETS=(
    "$DATA_DIR/health.training"      
    "$DATA_DIR/health.training"   
    "$DATA_DIR/tourism.training"
    "$DATA_DIR/tourism.training"
)
VALID_SETS=(
    "$DATA_DIR/health.dev"
    "$DATA_DIR/health.dev"
    "$DATA_DIR/tourism.dev"  
    "$DATA_DIR/tourism.dev" 
)
TEST_SETS=(
    "$DATA_DIR/health.test" 
    "$DATA_DIR/health.test"
    "$DATA_DIR/tourism.test" 
    "$DATA_DIR/tourism.test"  
)

if [ ! -d $DATA/en-brx ]; then
    echo "Data directory not found. Please run 'bash download-data.sh' first..."
    exit -1
fi

# download and extract data
echo "Already downloaded data"

echo "pre-processing train data..."
bash $SCRIPTS/download_indic.sh
for FILE in "${TRAIN_SETS[@]}" ; do
    $SRC_TOKENIZER $DATA/$FILE.$SRC
done > $TMP/train.$SRC
for FILE in "${TRAIN_SETS[@]}"; do
    $TGT_TOKENIZER $DATA/$FILE.$TGT
done > $TMP/train.$TGT

echo "pre-processing dev/test data..."
#bash $SCRIPTS/download_indic.sh
for FILE in "${VALID_SETS[@]}" ; do
    $SRC_TOKENIZER $DATA/$FILE.$SRC
done > $TMP/valid.$SRC
for FILE in "${VALID_SETS[@]}"; do
    $TGT_TOKENIZER $DATA/$FILE.$TGT
done > $TMP/valid.$TGT

for FILE in "${TEST_SETS[@]}" ; do
    $SRC_TOKENIZER $DATA/$FILE.$SRC
done > $TMP/test.$SRC
for FILE in "${TEST_SETS[@]}"; do
    $TGT_TOKENIZER $DATA/$FILE.$TGT
done > $TMP/test.$TGT
# learn BPE with sentencepiece
python $SPM_TRAIN \
  --input=$TMP/train.$SRC,$TMP/train.$TGT \
  --model_prefix=$DATABIN/sentencepiece.bpe \
  --vocab_size=$BPESIZE \
  --character_coverage=1.0 \
  --model_type=bpe

# encode train/valid/test
python $SPM_ENCODE \
  --model $DATABIN/sentencepiece.bpe.model \
  --output_format=piece \
  --inputs $TMP/train.$SRC $TMP/train.$TGT \
  --outputs $TMP/train.bpe.$SRC $TMP/train.bpe.$TGT \
  --min-len $TRAIN_MINLEN --max-len $TRAIN_MAXLEN
for SPLIT in "valid" "test"; do \
  python $SPM_ENCODE \
    --model $DATABIN/sentencepiece.bpe.model \
    --output_format=piece \
    --inputs $TMP/$SPLIT.$SRC $TMP/$SPLIT.$TGT \
    --outputs $TMP/$SPLIT.bpe.$SRC $TMP/$SPLIT.bpe.$TGT
done

# binarize data
fairseq-preprocess \
  --source-lang $SRC --target-lang $TGT \
  --trainpref $TMP/train.bpe --validpref $TMP/valid.bpe --testpref $TMP/test.bpe \
  --destdir $DATABIN \
  --joined-dictionary \
  --workers 4

