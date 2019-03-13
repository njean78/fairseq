# FAIRSEQ for it - en
First of all download the data of the european parlament in examples\translation\wmt14_it_en (files: europarl-v7.it-en.en and europarl-v7.it-en.it)

## preprocessing
Open cygwin and run the bash script prepare-wmt14en2it.sh ... it might work...

This step does :

* tokenization
* BPE

## binarize the data

from the fairseq directory run (windows command prompt and env fastai-gpu)
`
python preprocess.py --source-lang it --target-lang en --trainpref examples/translation/wmt14_it_en/train --validpref examples/translation/wmt14_it_en/valid --testpref examples/translation/wmt14_it_en/test --destdir data-bin/wmt14_it_en_bpe --workers 12
`

This script creates the embeddings, the dictionaries and the binary files to feed to fairseq

## run fairseq

-- max-tokens 3000
`
mkdir -p checkpoints/fconv_it_en
python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 3000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_en_fr --save-dir checkpoints/fconv_it_en --fp16 --warmup-updates 4000
`
## model creation
`
python scripts/average_checkpoints.py --inputs checkpoints/fconv_it_en --num-epoch-checkpoints 10 --output checkpoints/fconv_it_en/model.pt
`


## resume training fairseq

`
python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 3000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_en_fr --save-dir checkpoints/fconv_it_en --fp16 --restore-file checkpoint_best.pt
`

## fairseq with fasttext embedding

`
python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 10000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_fasttext --fp16 --encoder-embed-path C:/data/NLP/en-it/wiki.it/wiki.it.vec --encoder-embed-dim 300  --decoder-embed-path C:/data/NLP/en-it/wiki.en/wiki.en.vec --decoder-embed-dim 300 --decoder-out-embed-dim 300
`

## fairseq with bpe embedding

embedding from https://nlp.h-its.org/bpemb

these embedding are not that good at all...they are almost incompatible with the ones I get in fairseq...fairseq is more similar to a tokeinzation + some bpe... weird ...

`
python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 10000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_bpe --fp16 --encoder-embed-path C:/data/NLP/en-it/wiki.it/it.wiki.bpe.vs100000.d300.w2v.txt --encoder-embed-dim 300  --decoder-embed-path C:/data/NLP/en-it/wiki.en/en.wiki.bpe.vs100000.d300.w2v.txt --decoder-embed-dim 300 --decoder-out-embed-dim 300
`

More sentences (40000 bpe)
`
python train.py data-bin/wmt14_it_en_bpe --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 10000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_bpe_big --fp16 --encoder-embed-path C:/data/NLP/en-it/wiki.it/it.wiki.bpe.vs50000.d300.w2v.txt --encoder-embed-dim 300  --decoder-embed-path C:/data/NLP/en-it/wiki.en/en.wiki.bpe.vs50000.d300.w2v.txt --decoder-embed-dim 300 --decoder-out-embed-dim 300
`

35 482 654

## fairseq with flair embedding

generate the dictionary by running :
`
python create_flair_embedding.py
`
then run
`
python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 6000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_flair --fp16 --encoder-embed-path C:/data/NLP/en-it/wiki.it/flair.it --encoder-embed-dim 512 --decoder-embed-dim 512 --decoder-out-embed-dim 512
`


## use fairseq on binarized data

* patch bleu score :https://github.com/pytorch/fairseq/issues/292
* rebuild the fairseq package
* run the generator:
`
python generate.py data-bin/wmt14_it_en_bpe --path checkpoints/fconv_it_en/checkpoint_best.pt  --beam 5  --remove-bpe --quiet | C:\Software\UnxUtils\usr\local\wbin\tee.exe C:\tmp\gen.out
`

## use fairseq interactive on raw sentences
`
python interactive.py --path checkpoints/fconv_it_en/checkpoint_best.pt --source-lang it --target-lang en --beam 5 checkpoints/fconv_it_en/
`

# Dataset enrichment
For the translator we are using the Europarlement v7 dataset. We are going to enrich it with some general knowledge :
http://opus.nlpl.eu/download.php?f=EUbookshop/v2/moses/en-it.txt.zip


#############

python preprocess.py --source-lang it --target-lang en --trainpref examples/translation/wmt14_it_en/train --validpref examples/translation/wmt14_it_en/valid --testpref examples/translation/wmt14_it_en/test --destdir data-bin/wmt14_it_en_bpe_clean2 --workers 12

python train.py data-bin/wmt14_it_en_bpe_clean2 --lr 0.9 --clip-norm 0.1 --dropout 0.1 --max-tokens 10000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_bpe_clean2 --fp16 --warmup-updates 4000

## try lightconv
python train.py data-bin/wmt14_it_en_bpe_clean2 --lr 0.9 --clip-norm 0.1 --dropout 0.1 --max-tokens 8000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch lightconv_wmt_zh_en_big --save-dir checkpoints/fconv_it_en_bpe_clean2 --fp16 --warmup-updates 4000


python train.py data-bin/wmt14_it_en_bpe_clean2 --lr 0.9 --clip-norm 0.1 --dropout 0.1 --max-tokens 9000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch lightconv_wmt_zh_en_big --save-dir checkpoints/fconv_it_en_bpe_clean2 --fp16 --warmup-updates 4000 --restore-file checkpoint_best.pt





python train.py data-bin/wmt14_it_en --lr 0.5 --clip-norm 0.1 --dropout 0.1 --max-tokens 3000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch fconv_wmt_en_fr --save-dir checkpoints/fconv_it_en --fp16

python train.py data-bin/wmt14_it_en_clean --lr 0.9 --clip-norm 0.1 --dropout 0.1 --max-tokens 10000 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --lr-scheduler fixed --force-anneal 50 --arch lightconv_wmt_en_fr_big --save-dir checkpoints/fconv_it_en_bpe_clean --fp16 --encoder-embed-path C:/data/NLP/en-it/wiki.it/it.wiki.bpe.vs50000.d300.w2v.txt --encoder-embed-dim 300  --decoder-embed-path C:/data/NLP/en-it/wiki.en/en.wiki.bpe.vs50000.d300.w2v.txt --decoder-embed-dim 300 --decoder-out-embed-dim 300


python train.py data-bin/wmt14_it_en_bpe_clean2 --max-lr 0.9 --clip-norm 0.1 --dropout 0.1 --max-tokens 15000 --criterion label_smoothed_cross_entropy --lr-scheduler triangular --arch fconv_wmt_it_en --save-dir checkpoints/fconv_it_en_bpe_clean2 --fp16  --encoder-embed-dim 300   --decoder-embed-dim 300 --decoder-out-embed-dim 300 --restore-file checkpoint_last.pt


python generate.py data-bin/wmt14_it_en_bpe_clean2 --max-tokens 5000 --fp16 --path checkpoints/fconv_it_en_bpe_clean2/checkpoint_best.pt  --beam 5  --remove-bpe --quiet --skip-invalid-size-inputs-valid-test | C:\Software\UnxUtils\usr\local\wbin\tee.exe C:\tmp\gen.out
