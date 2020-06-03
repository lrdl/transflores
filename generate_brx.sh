fairseq-generate     data-bin/brx_en_bpe10000/ --source-lang brx --target-lang en --path checkpoints/brx_en/checkpoint_best.pt    \
	 --beam 5 --lenpen 1.2     --gen-subset valid     --remove-bpe=sentencepie
