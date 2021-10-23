#!/bin/bash
cd "/data/pt_02133/1-scripts/navigators/"
directory="/data/pt_02133/1-scripts/navigators/"
data_folder="/data/pt_02133/incoming/"
raw_folder="s008/s008_7T_20200122_MR1/h5/"
raw_data="raw_s008.txt"

lines=`cat $directory$raw_data`
ind=0
for line in $lines;
do
	rawFile_array[$ind]="$data_folder$raw_folder$line"
	((ind=ind+1))
done

export MATLABPATH=/data/pt_02133/1-scripts/navigators/

for raw in ${rawFile_array[1]}
do      
        MATLAB --version 9.7 matlab -nodisplay -nodesktop -nosplash -r "recon_corr_varadaptive_virt('$raw', '$raw_folder',40,10000,4);exit;"
#gzip $raw
done
cd "/data/pt_02133/1-scripts/navigators/"
# 
