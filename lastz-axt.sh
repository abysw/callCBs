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

### Chain Net 
axtSort $RM-$QM.axt $RM-$QM.sorted.axt
axtChain -linearGap=/public/agis/chengshifeng_group/fuyuan/pip-fuyuan/GAP_matrix_plant.dms $RM-$QM.sorted.axt $RN.2bit $QN.2bit $RM-$QM.sorted.filtered.chain
chainPreNet $RM-$QM.sorted.filtered.chain $RN.sizes $QN.sizes $RM-$QM.sorted.filtered.pre.chain
chainNet $RM-$QM.sorted.filtered.pre.chain -minSpace=1 $RN.sizes $QN.sizes stdout /dev/null | netSyntenic stdin $RM-$QM.sorted.filtered.pre.noClass.net

### trans format
cp $RM-$QM.sorted.filtered.pre.noClass.net $RM-$QM.net
netToAxt $RM-$QM.net $RM-$QM.sorted.filtered.pre.chain $RN.2bit $QN.2bit stdout | axtSort stdin $RM-$QM.net.sorted.axt
axtToMaf $RM-$QM.net.sorted.axt $RN.sizes $QN.sizes $RM-$QM.net.sorted.axt.maf

less $RM-$QM.net.sorted.axt.maf | perl -ne 'if (/^a/){print \$_;\$i=<STDIN>;\$i=~s/^s\\ /s\\ $RM\./;\$j=<STDIN>;\$j=~s/^s\\ /s\\ $QM\./;print \$i.\$j;}else{print \$_;}' > $RM-$QM.maf
maf_sort $RM-$QM.maf $RM > $RM-$QM.orig.maf
single_cov2 $RM-$QM.orig.maf R=$RM > $RM-$QM.sing.maf
if [ ! -f "../maf" ];then
	mkdir ../maf
fi
cp $RM-$QM.sing.maf ../maf/$RM.$QM.sing.maf
rm *sorted* *2bit 
echo Finished!!!
echo The result is in $PWD/../maf/$RM.$QM.sing.maf
" > $RM-$QM/$RM-$QM-blastz.sh
