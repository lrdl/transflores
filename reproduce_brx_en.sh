# Copyright (c) Facebook, Inc. and its affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
#!/bin/bash
# Script to reproduce iterative back-translation baseline

SUPPORT_LANG_PAIRS="brx_en"

if [[ $# -lt 1 ]] || ! [[ "$1" =~ ^($SUPPORT_LANG_PAIRS)$ ]]; then
  echo "Usage: $0 LANGUAGE_PAIR($SUPPORT_LANG_PAIRS)"
  exit 1
fi

LANG_PAIR=$1

if [[ $LANG_PAIR = "brx_en" ]]; then
  python scripts/train.py --config configs/enbrx.json --databin $PWD/data-bin/brx_en_bpe10000/
fi
