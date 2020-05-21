#!/bin/bash

SCRIPTS_DIR="/glade/work/djk2120/ctsm_hardcode_co/cime/scripts/"
SPINDIR="/glade/scratch/djk2120/UMBens/"
SCRATCH="/glade/scratch/djk2120/"

cd $SCRIPTS_DIR
for i in $(seq -f "%03g" 1 5)
do
    p="umbrun_"$i
    cd $p
    keyfile=$p"_key.txt"
    d=$SCRATCH$p"/run/"
    cd $d
    endstr=$(ls *.h1.* | head -n 1 | cut -c21-)
    echo $endstr
    cd -

    while read -r line; do 
	tmp=(${line///}) 
	paramkey=${tmp[1]} 
	instkey=${tmp[0]}

	oldfile=$d$p".clm2_"$instkey".h1.*"
	newfile=$SPINDIR$paramkey".clm2"$endstr

	cp $oldfile $newfile
    done < $keyfile
    cd ..
done
