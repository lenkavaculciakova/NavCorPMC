#!/bin/bash
cd "/data/pt_02133/1-scripts/navigators/"
directory="/data/pt_02133/1-scripts/navigators/"
data_folder="/data/pt_02133/incoming/"
raw_folder="s006/s006_7T_20191218_MR1/h5/"
raw_data="raw_s006.txt"

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
        gunzip $raw.gz
        MATLAB --version 9.7 matlab -nodisplay -nodesktop -nosplash -r "recon_uncor('$raw', '$raw_folder');exit;"
        #gzip $raw
done
cd "/data/pt_02133/1-scripts/navigators/"
# 
