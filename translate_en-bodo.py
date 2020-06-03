from fairseq.models.transformer import TransformerModel
brx2en = TransformerModel.from_pretrained(
  'checkpoints/brx_en',
  checkpoint_file='checkpoint_best.pt',
  data_name_or_path='data-bin/brx_en_bpe10000',
  bpe='sentencepiece',
  model_file='data-bin/brx_en_bpe10000/sentencepiece.bpe.model',
  sentencepiece_vocab='data-bin/brx_en_bpe10000/sentencepiece.bpe.vocab'
)
text='देहा बिबानगिरिफोरजों नायजादोंमोन'
print('src: '+text+'\n'+'trnas:' + brx2en.translate(text))
#print(zh2en.eval())
