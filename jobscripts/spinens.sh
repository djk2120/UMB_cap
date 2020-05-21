SCRIPTS_DIR="/glade/work/djk2120/ctsm_hardcode_co/cime/scripts/"
basecase="spinclm50drdfd89sp_US-UMB_I1PtClm50SpRsGs"
PARAMS_DIR="/glade/u/home/djk2120/umbcap/params/paramfiles/"
NLMODS_DIR="/glade/u/home/djk2120/umbcap/params/namelist_mods/"
BUILD_DIR="'/glade/scratch/djk2120/umbspin_001/bld'"
ninst=30

PWD=$(pwd)

#count existing cases
cd $SCRIPTS_DIR
if [ -d umbspin_001 ]
then
    s=$(find umbspin_* -maxdepth 0 | wc -l)
    s=$((s+1))
else s=1
fi
cd -

ninst0=$ninst
pstr1="paramfile = '"
pstr2="'"
np=$(ls ../params/paramfiles/spinme | wc -l)


while [ $np -gt 0 ]
do
    casename="umbspin_"$(seq -f "%03g" $s $s)
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
      ./create_clone --case $casename --clone umbspin_001
      cd $casename
      ./case.setup --reset
      ./xmlchange EXEROOT=$BUILD_DIR
      ./xmlchange BUILD_COMPLETE=TRUE
  fi
  cd -
      
  cd $PARAMS_DIR
  CT=0
  for path in spinme/*.nc
  do
      CT=$((CT+1))
      if [ $CT -lt $((ninst+1)) ]
      then
	  mv $path spun/
	  f="$(basename -- $path)"
	  pfile_path=$PARAMS_DIR"spun/"$f
	  nlmods=$NLMODS_DIR${f%.*}".txt"
	  
 	  cd $SCRIPTS_DIR$casename
	  printf -v nlnum "%04d" $CT
	  nlfile="user_nl_clm_"$nlnum
	  cp user_nl_clm.base $nlfile
	  echo $pstr1$pfile_path$pstr2 >> $nlfile
	  cat $nlmods >> $nlfile
	  printf $nlnum"\t"${f%.*}"\n" >> $casename"_key.txt"
	  cd $PARAMS_DIR
      fi
  done
  
  cd $SCRIPTS_DIR$casename
  if [ $s -eq 1 ]
  then
      ./case.build
      ./case.submit
  else
      ./case.submit
  fi
  np=$(($np-$ninst))
  s=$(($s+1))
done
cd $PWD

