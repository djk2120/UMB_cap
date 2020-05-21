s=121
e=150
FROMDIR="done/"
TODIR="spun/"
for p in $(seq -f "%04g" $s $e)
do
    f=$FROMDIR"US-UMB_GPPcap_LHC"$p".nc"
    mv $f $TODIR
done
