## callCBs: A pipeline for call Conserved Blocks from multiple sequence alignment
#### please use conda3/python3

## 1. install tools 
#### install bedtools
$ conda install bedtools

#### install lastz
> http://www.bx.psu.edu/~rsharris/lastz/README.lastz-1.04.03.html#install

#### install multiz-tba.012109
> https://www.bx.psu.edu/miller_lab/dist/multiz-tba.012109.tar.gz

### obtain this pipeline
$ git clone https://github.com/Yuan-SW-F/callCBs.git

## 2. prepare files
$ sh lastz-axt.sh genomeA.fasta  genomeA.fasta
$ roast "the phylogenetic tree" *sing.maf roast.maf

## 3. callCBs (main pipeline)
cd test
sh ../CallCBs.sh
