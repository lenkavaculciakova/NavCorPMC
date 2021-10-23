#!/bin/bash
cd "/data/pt_02133/1-scripts/navigators/"
directory="/data/pt_02133/1-scripts/navigators/"
data_folder="/data/pt_02133/incoming/"
raw_folder="s009/s009_7T_20200310_MR1/h5/"
raw_data="raw_s009.txt"

lines=`cat $directory$raw_data`
ind=0
for line in $lines;
do
	rawFile_array[$ind]="$data_folder$raw_folder$line"
	((ind=ind+1))
done

export MATLABPATH=/data/pt_02133/1-scripts/navigators/

for raw in ${rawFile_array[@]}
do        
        MATLAB --version 9.7 matlab -nodisplay -nodesktop -nosplash -r "recon_uncor('$raw', '$raw_folder');exit;"
done
cd "/data/pt_02133/1-scripts/navigators/"
# 
