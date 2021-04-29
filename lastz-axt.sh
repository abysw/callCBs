#!/bin/bash
# File Name: lastz-axt.sh
# Author  : Yuan-SW-F, yuanswf@163.com
# Created Time: 2019-04-15 16:30:26
source /public/home/fuyuan/.bashrc
### input ref query
RN=`echo $1|perl -ne '/((\w+)[^\/]+)$/;print $1'`;
RM=`echo $1|perl -ne '/((\w+)[^\/]+)$/;print $2'`;
QN=`echo $2|perl -ne '/((\w+)[^\/]+)$/;print $1'`;
QM=`echo $2|perl -ne '/((\w+)[^\/]+)$/;print $2'`;

mkdir $RM-$QM;
echo "source /public/home/fuyuan/.bashrc
### build
if [ ! -e $1.fai ];then
	samtools faidx $1
fi
faToTwoBit $1 $RN.2bit
faSize $1 -detailed > $RN.sizes

faToTwoBit $2 $QN.2bit
faSize $2 -detailed > $QN.sizes

### lastz
lastz $1[multiple] $2[multiple] --ambiguous=iupac --chain --notransition H=2000 Y=3000 L=3000 K=2200 --format=axt --gfextend > $RM-$QM.axt
# lastz $1[multiple] $2[multiple] H=2000 X=9400 L=3000 K=2200 --format=axt > $RM-$QM.axt # xhj
# lastz $1[multiple] $2[multiple] --gapped --ambiguous=n --step=10 --strand=both --masking=10 --maxwordcount=500 --identity=70..100 --format=axt > $RM-$QM.axt #gold fish

### axt Chain Net 
axtSort $RM-$QM.axt $RM-$QM.sorted.axt
# axtBest -minOutSize=200 -minScore=10000 $RM-$QM.sorted.axt all $RM-$QM.sorted.best.axt
ln -s $RM-$QM.sorted.axt $RM-$QM.sorted.best.axt
axtChain -linearGap=/public/agis/chengshifeng_group/fuyuan/pip-fuyuan/GAP_matrix_plant.dms $RM-$QM.sorted.best.axt $RN.2bit $QN.2bit $RM-$QM.sorted.best.filtered.chain
chainPreNet $RM-$QM.sorted.best.filtered.chain $RN.sizes $QN.sizes $RM-$QM.sorted.best.filtered.pre.chain
chainNet $RM-$QM.sorted.best.filtered.pre.chain -minSpace=1 $RN.sizes $QN.sizes stdout /dev/null | netSyntenic stdin $RM-$QM.sorted.best.filtered.pre.noClass.net

### trans
cp $RM-$QM.sorted.best.filtered.pre.noClass.net $RM-$QM.net
netToAxt $RM-$QM.net $RM-$QM.sorted.best.filtered.pre.chain $RN.2bit $QN.2bit stdout | axtSort stdin $RM-$QM.net.sorted.axt
axtToMaf $RM-$QM.net.sorted.axt $RN.sizes $QN.sizes $RM-$QM.net.sorted.axt.maf
maf-convert sam $RM-$QM.net.sorted.axt.maf > $RM-$QM.net.sorted.axt.maf.sam
# samtools view -bt $1.fai $RM-$QM.net.sorted.axt.maf.sam > $RM-$QM.net.sorted.axt.maf.bam
# samtools sort $RM-$QM.net.sorted.axt.maf.bam > $RM-$QM.net.sorted.axt.maf.sorted.bam
# samtools index $RM-$QM.net.sorted.axt.maf.sorted.bam
# bamToBed -i $RM-$QM.net.sorted.axt.maf.sorted.bam > $RM-$QM.net.sorted.axt.maf.sorted.bam.bed
# sort -k1,1 -k2,2n  $RM-$QM.net.sorted.axt.maf.sorted.bam.bed > $RM-$QM.net.sorted.axt.maf.sorted.bam.sorted.bed
# bedtools merge -i $RM-$QM.net.sorted.axt.maf.sorted.bam.sorted.bed > $RM-$QM.net.sorted.axt.maf.sorted.bam.sorted.merged.bed
# mv $RM-$QM.net.sorted.axt.maf.sorted.bam.sorted.merged.bed $RM-$QM.bed

less $RM-$QM.net.sorted.axt.maf | perl -ne 'if (/^a/){print \$_;\$i=<STDIN>;\$i=~s/^s\\ /s\\ $RM\./;\$j=<STDIN>;\$j=~s/^s\\ /s\\ $QM\./;print \$i.\$j;}else{print \$_;}' > $RM-$QM.maf
maf_sort $RM-$QM.maf $RM > $RM-$QM.orig.maf
single_cov2 $RM-$QM.orig.maf R=$RM > $RM-$QM.sing.maf
if [ ! -f "../maf" ];then
	mkdir ../maf
fi
cp $RM-$QM.sing.maf ../maf/$RM.$QM.sing.maf
rm *sorted* *2bit 
" > $RM-$QM/$RM-$QM-blastz.sh
