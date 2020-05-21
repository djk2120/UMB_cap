SCRIPTS_DIR="/glade/work/djk2120/ctsm_hardcode_co/cime/scripts/"
basecase="drdfclm50d89wspinsp_US-UMB_I1PtClm50SpRsGs"
PARAMS_DIR="/glade/u/home/djk2120/umbcap/params/paramfiles/"
NLMODS_DIR="/glade/u/home/djk2120/umbcap/params/namelist_mods/"
BUILD_DIR="'/glade/scratch/djk2120/umbrun_001/bld'"
RESTARTS="/glade/scratch/djk2120/UMBens/"
ninst=30

PWD=$(pwd)


#count existing cases
cd $SCRIPTS_DIR
if [ -d umbrun_001 ]
then
    s=$(find umbrun_* -maxdepth 0 | wc -l)
    s=$((s+1))
else s=1
fi
cd -


np=$(ls ../params/paramfiles/spun | wc -l)
ninst0=$ninst

while [ $np -gt 0 ]
do
#    casename="umbrun_"$(seq -f "%03g" $s $s)

    s=1
    casename="umbrun_005"


    echo $casename
    if [ $np -lt $ninst ]
    then
	ninst=$np
    fi


    cd $SCRIPTS_DIR
    if [ $s -eq 1 ]
    then
	./create_clone --case $casename --clone $basecase
	cd $casename
	./xmlchange MAX_TASKS_PER_NODE=36
	./xmlchange MAX_MPITASKS_PER_NODE=36
	./xmlchange MPILIB="mpt"
	./xmlchange NINST_LND=$ninst
	./case.setup --reset
    else
	./create_clone --case $casename --clone umbrun_001
	cd $casename
	./case.setup --reset
	./xmlchange EXEROOT=$BUILD_DIR
	./xmlchange BUILD_COMPLETE=TRUE
    fi
    cd -

    cd $PARAMS_DIR
    CT=0
    for path in spun/*.nc
    do
	CT=$((CT+1))
	if [ $CT -lt $((ninst+1)) ]
	then
	    mv $path done/
	    f="$(basename -- $path)"
	    pfile_path=$PARAMS_DIR"done/"$f
	    nlmods=$NLMODS_DIR${f%.*}".txt"
	    cd $SCRIPTS_DIR$casename
	    printf -v nlnum "%04d" $CT
	    nlfile="user_nl_clm_"$nlnum
	    cp user_nl_clm.base $nlfile
	    echo $pstr1$pfile_path$pstr2 >> $nlfile
	    r=$RESTARTS${f%.*}"*.r.*nc"
	    finidat=$(ls $r)
	    echo "finidat = '"$finidat"'" >> $nlfile
	    cat $nlmods >> $nlfile
	    printf $nlnum"\t"${f%.*}"\n" >> $casename"_key.txt"
	    cd $PARAMS_DIR
	fi
    done


    cd $SCRIPTS_DIR$casename
    if  [ $s -eq 1 ]
    then
	./case.build
	./case.submit
    elif [ $ninst -eq $ninst0 ]
    then
	./case.submit
    else
	./case.build
	./case.submit
    fi
    
np=$(($np-$ninst))
s=$(($s+1))
done
cd $PWD

