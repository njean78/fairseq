#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git

export SCRIPTS=mosesdecoder/scripts
#TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
#CLEAN=$SCRIPTS/training/clean-corpus-n.perl
#NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
#REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
#BPEROOT=subword-nmt
#BPE_TOKENS=40000

#URLS=(
#    "http://statmt.org/wmt13/training-parallel-europarl-v7.tgz"
#)
#FILES=(
#    "training-parallel-europarl-v7.tgz" ## got them
#)
#CORPORA=(
#    "training/europarl-v7.it-en"
#    "commoncrawl.it-en"
#    "training/news-commentary-v12.it-en"
#)


#if [ ! -d "$SCRIPTS" ]; then
#    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
#    exit

#src=it
#tgt=en
#lang=it-en
#prep=wmt14_it_en
#tmp=$prep/tmp
#orig=orig
#dev=dev/newstest2013

mkdir -p orig wmt14_it_en wmt14_it_en/tmp 

#mkdir -p $orig $tmp $prep
################### TOKENIZE

## first dataset
cat wmt14_it_en/europarl-v7.it-en.en | perl $SCRIPTS/tokenizer/normalize-punctuation.perl en | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl | perl $SCRIPTS/tokenizer/lowercase.perl > wmt14_it_en/tmp/pre_token.en 
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl  -threads 16 -a -l en < wmt14_it_en/tmp/pre_token.en >> wmt14_it_en/tmp/train.tags.it-en.tok.en
cat wmt14_it_en/europarl-v7.it-en.it | perl $SCRIPTS/tokenizer/normalize-punctuation.perl it | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl > wmt14_it_en/tmp/pre_token.it
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 16 -a -l it < wmt14_it_en/tmp/pre_token.it >> wmt14_it_en/tmp/train.tags.it-en.tok.it

## second dataset
cat wmt14_it_en/EUbookshop.en-it.en | perl $SCRIPTS/tokenizer/normalize-punctuation.perl en | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl > wmt14_it_en/tmp/pre_token.en 
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl  -threads 16 -a -l en -time < wmt14_it_en/tmp/pre_token.en >> wmt14_it_en/tmp/train2.tags.it-en.tok.en
cat wmt14_it_en/EUbookshop.en-it.it | perl $SCRIPTS/tokenizer/normalize-punctuation.perl it | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl > wmt14_it_en/tmp/pre_token.it
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 16 -a -l it -time < wmt14_it_en/tmp/pre_token.it >> wmt14_it_en/tmp/train2.tags.it-en.tok.it


## merge the training sets
cat  wmt14_it_en/tmp/train.tags.it-en.tok.en wmt14_it_en/tmp/train2.tags.it-en.tok.en > wmt14_it_en/tmp/pre_token.en
mv  wmt14_it_en/tmp/pre_token.en wmt14_it_en/tmp/train.tags.it-en.tok.en

cat  wmt14_it_en/tmp/train.tags.it-en.tok.it wmt14_it_en/tmp/train2.tags.it-en.tok.it > wmt14_it_en/tmp/pre_token.it
mv  wmt14_it_en/tmp/pre_token.it wmt14_it_en/tmp/train.tags.it-en.tok.it
############################################## lower version already merged
## add extra spaces
# sed -e 's/\./\. /g' wmt14_it_en/all_big.en > tmp.en
# mv tmp.en wmt14_it_en/all_big.en

# sed -e 's/\?/\? /g' wmt14_it_en/all_big.en > tmp.en
# mv tmp.en wmt14_it_en/all_big.en

# sed -e 's/\!/\! /g' wmt14_it_en/all_big.en > tmp.en
# mv tmp.en wmt14_it_en/all_big.en

# ## add extra spaces
# sed -e 's/\./\. /g' wmt14_it_en/all_big.it > tmp.it
# mv tmp.it wmt14_it_en/all_big.it

# sed -e 's/\?/\? /g' wmt14_it_en/all_big.it > tmp.it
# mv tmp.it wmt14_it_en/all_big.it

# sed -e 's/\!/\! /g' wmt14_it_en/all_big.it > tmp.it
# mv tmp.it wmt14_it_en/all_big.it

cat wmt14_it_en/all_big.en | perl $SCRIPTS/tokenizer/normalize-punctuation.perl en | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl > wmt14_it_en/tmp/pre_token.en 
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl  -threads 16 -a -l en -time < wmt14_it_en/tmp/pre_token.en >> wmt14_it_en/tmp/train_all.tags.it-en.tok.en
cat wmt14_it_en/all_big.it | perl $SCRIPTS/tokenizer/normalize-punctuation.perl it | perl $SCRIPTS/tokenizer/remove-non-printing-char.perl > wmt14_it_en/tmp/pre_token.it
## run me on cmd windows
perl mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 16 -a -l it -time < wmt14_it_en/tmp/pre_token.it >> wmt14_it_en/tmp/train_all.tags.it-en.tok.it

mv  wmt14_it_en/tmp//train_all.tags.it-en.tok.en wmt14_it_en/tmp/train.tags.it-en.tok.en
mv  wmt14_it_en/tmp//train_all.tags.it-en.tok.it wmt14_it_en/tmp/train.tags.it-en.tok.it
## tokenize using moses
#echo "pre-processing train data..."
#for l in $src $tgt; do
#    rm $tmp/train.tags.$lang.tok.$l
#    for f in "${CORPORA[@]}"; do
#        cat $orig/$f.$l | \
#            perl $NORM_PUNC $l | \
#            perl $REM_NON_PRINT_CHAR | \
#            perl $TOKENIZER -threads 8 -a -l $l >> $tmp/train.tags.$lang.tok.$l
#    done
#done
################### SPLIT train-validation-test
cd wmt14_it_en/tmp
awk '{if (NR%200 == 0)  print $0; }' train.tags.it-en.tok.en > valid.en
awk '{if (NR%200 != 0)  print $0; }' train.tags.it-en.tok.en > temp.en
## add test
awk '{if (NR%200 == 0)  print $0; }' temp.en > test.en
awk '{if (NR%200 != 0)  print $0; }' temp.en > train.en
rm temp.en

awk '{if (NR%200 == 0)  print $0; }' train.tags.it-en.tok.it > valid.it
awk '{if (NR%200 != 0)  print $0; }' train.tags.it-en.tok.it > temp.it
## add test
awk '{if (NR%200 == 0)  print $0; }' temp.it > test.it
awk '{if (NR%200 != 0)  print $0; }' temp.it > train.it
rm temp.it

#echo "splitting train and valid..."
#for l in $src $tgt; do
#    awk '{if (NR%100 == 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/valid.$l
#    awk '{if (NR%100 != 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/train.$l
#done

## cat the training sets
cat train.it > train.it-en
cat train.en >> train.it-en
mv train.it-en ../../train.it-en
#TRAIN=train.de-en
#BPE_CODE=$prep/code
#rm -f $TRAIN
#for l in $src $tgt; do
#    cat $tmp/train.$l >> $TRAIN
#done
################### create the BPE
cd ../../subword-nmt/
python "subword_nmt/learn_bpe.py" -s 40000 < ../train.it-en > ../wmt14_it_en/code
## python "subword_nmt/learn_bpe.py" -s 100000 < ../train.it-en > ../wmt14_it_en/code_100000
#echo "learn_bpe.py on ${TRAIN}..."
#python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE
################### apply the BPE
python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/train.en > ../wmt14_it_en/tmp/bpe.train.en
python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/valid.en > ../wmt14_it_en/tmp/bpe.valid.en
python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/test.en > ../wmt14_it_en/tmp/bpe.test.en

python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/train.it > ../wmt14_it_en/tmp/bpe.train.it
python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/valid.it > ../wmt14_it_en/tmp/bpe.valid.it
python "subword_nmt/apply_bpe.py" -c ../wmt14_it_en/code < ../wmt14_it_en/tmp/test.it > ../wmt14_it_en/tmp/bpe.test.it

cd ../



#for L in $src $tgt; do
#    for f in train.$L valid.$L test.$L; do
#        echo "apply_bpe.py to ${f}..."
#        python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/$f > $tmp/bpe.$f
#    done
#done
################### clean the corpus

perl mosesdecoder/scripts/training/clean-corpus-n.perl -ratio 1.5 ./wmt14_it_en/tmp/bpe.train it en ./wmt14_it_en/train 1 250
perl mosesdecoder/scripts/training/clean-corpus-n.perl -ratio 1.5 ./wmt14_it_en/tmp/bpe.valid it en ./wmt14_it_en/valid 1 250

#perl $CLEAN -ratio 1.5 $tmp/bpe.train $src $tgt $prep/train 1 250
#perl $CLEAN -ratio 1.5 $tmp/bpe.valid $src $tgt $prep/valid 1 250

cp ./wmt14_it_en/tmp/bpe.test.it ./wmt14_it_en/test.it
cp ./wmt14_it_en/tmp/bpe.test.en ./wmt14_it_en/test.en
#for L in $src $tgt; do
#    cp $tmp/bpe.test.$L $prep/test.$L
#done
