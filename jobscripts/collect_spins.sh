#!/bin/bash
SCRIPTS_DIR="/glade/work/djk2120/ctsm_hardcode_co/cime/scripts/"
SPINDIR="/glade/scratch/djk2120/UMBens2/"
SCRATCH="/glade/scratch/djk2120/"
cd $SCRIPTS_DIR
for i in $(seq -f "%03g" 6 15)
do
    p="umbspin_"$i
    echo $p
    cd $p
    keyfile=$p"_key.txt"
    d=$SCRATCH$p"/run/"
    cd $d
    endstr=$(ls *.r.* | head -n 1 | cut -c22-)
    echo $endstr
    cd -

    while read -r line; do 
	tmp=(${line///}) 
	paramkey=${tmp[1]} 
	instkey=${tmp[0]}

	oldfile=$d$p".clm2_"$instkey".r.*"
	newfile=$SPINDIR$paramkey".clm2"$endstr


	cp $oldfile $newfile
    done < $keyfile
    cd ..
done
