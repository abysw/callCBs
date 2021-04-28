#!/bin/bash
# File Name: CallCBs.sh
# Author  : Yuan-SW-F, yuanswf@163.com
# github: https://github.com/Yuan-SW-F/callCBs
# Created Time: 2021-04-28 16:06:56
source ~/.bashrc

### Prepare 
# lastz for pairwise sequence alignment
# 	files: *sing.maf
# roast for multiple sequence alignment
# 	files: MtrunA17MT_Metru.roast.maf
# prepare Type files
# 	files: MtrunA17MT_Metru.CDS.gff, MtrunA17MT_Metru.UTR.gff
# prepate clade files
# 	files: NFC.lst, NFL.lst, NFN.lst

# import in house script
export PATH=/vol3/asbc/CHENGSHIFENG_GROUP/fuyuan/02.Nfix/00.81species_CNE/35.CNB/callCBs/callCBs:$PATH
# set chromosome
chr=MtrunA17MT_Metru

# merge and sort Type files
cat $chr.UTR.gff $chr.CDS.gff > $chr.ANN.gff
sortBed -i $chr.ANN.gff > $chr.ANN.gff.sorted

### Split Blocks by each Type
# prepare split region file
maf_sort $chr.roast.maf Medicago_truncatula > $chr.maf # sort maf.file
abyss maf2bed $chr.maf | sed s/Medicago_truncatula.// > $chr.rawCNE.bed # get multiple sequence blocks region
bedtools intersect -a $chr.rawCNE.bed -b $chr.ANN.gff.sorted > $chr.rawCNE.UTRi.bed # overlap region of Types
bedtools subtract -a $chr.rawCNE.bed -b $chr.ANN.gff.sorted > $chr.rawCNE.UTRs.bed # exclude Types region
cat $chr.rawCNE.UTRi.bed $chr.rawCNE.UTRs.bed > $chr.rawCNE.splited.unsorted.bed # merge all region
sortBed -i $chr.rawCNE.splited.unsorted.bed > $chr.rawCNE.splited.bed # sort

# extract conserved blocks (this step just for faster and more economocal running, so you can skip it by "cp $chr.roast.maf $chr.maf.blocks")
call_CBs.py $chr.roast.maf > $chr.maf.blocks # extract conserved blocks

# Split Blocks for selected chromosome
mkdir $chr && cd $chr
cp ../$chr.rawCNE.splited.bed $chr.bed
mafSplit $chr.bed $chr. ../$chr.maf.blocks
cd ..
echo "##maf version=1 scoring=maf_project.v12" > ./$chr.maf.raw
find ./$chr/ -name "*maf" | xargs cat | grep -v "#" >> $chr.maf.raw
echo "##eof maf" >> ./$chr.maf.raw
call_CBs.py ./$chr.maf.raw > ./$chr.maf.raw.f # extract conserved blocks
maf_sort ./$chr.maf.raw.f Medicago_truncatula > ./$chr.maf
rm -rf $chr
rm $chr.maf.*
rm $chr.rawCNE.*

### Extract Conserved Blocks for each Clades
mkdir clade
mkdir clade_block
cd clade
for c in `ls ../.. | grep -P "\.lst" | sed s/.lst//` ;do
	L=`cat ../../$c.lst | abyss lst`
	C=`cat ../../$c.lst | wc -l | perl -ne 'print int(0.9*$1 + 0.999) if /(\d+)/'`
	mkdir $c
	cd $c
	maf_order ../../$chr.maf $L > $chr.maf.order
	mafFilter -minRow=$C $chr.maf.order > $chr.maf.order.filter
	F=`echo $chr.maf.order.filter.$c-blocks.maf | perl -ne 's/.maf.order.filter//; print $1 if /(\S+)/'`
	cp $chr.maf.order.filter ../../clade_block/$F
	abyss maf2bed ../../clade_block/$F | sed s/Medicago_truncatula.// > ../../clade_block/$F.bed
	cd ..
done
cd ..

echo ""
echo "Finished!!! The result is located in ./clade_block."
