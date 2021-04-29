## callCBs: A pipeline for call Conserved Blocks from multiple sequence alignment
#### please use conda3/python3

## 1. install tools 
#### install bedtools
$ conda install bedtools

#### install lastz
> https://github.com/lastz/lastz

#### install multiz-tba.012109
> https://www.bx.psu.edu/miller_lab/dist/multiz-tba.012109.tar.gz

### obtain this pipeline
$ git clone https://github.com/Yuan-SW-F/callCBs.git

>> Write all tools into environment variables

## 2. prepare files
$ sh lastz-axt.sh genomeA.fasta  genomeB.fasta

$ roast "the phylogenetic tree" *sing.maf roast.maf

## 3. callCBs (main pipeline)
### For quick start:
cd test

sh test.sh

## Files in this pipeline
abyss                   # script for change file format

call_CBs.py             # core python3 script for call Conserved Blocks

CallCBs.sh              # main executable shell script for call Conserved Blocks

lastz                   # software for pairwise sequence alignment, could be download from github

lastz-axt.sh            # main executable shell script for pairwise sequence alignment

multiz-tba.012109/      # executable script of multiz-tba.012109

README.md               # This file

test/                   # test data and script
## Citing:
web: https://github.com/Yuan-SW-F/callCBs

article: 
