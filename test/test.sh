chmod 755 ../lastz-axt.sh ../call_CBs.py ../multiz-tba.012109/bin -R
export PATH=$PWD/../multiz-tba.012109/bin:$PATH
export PATH=$PWD/..:$PATH
gunzip MtrunA17MT_Metru.roast.maf.gz
sh ../CallCBs.sh
