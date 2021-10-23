#!/bin/bash
cd "/data/pt_02199/scripts"
directory="/data/pt_02199/images_filtered_navs/"
participant="2615341"
raw_folder="/raw/"
path="$directory$participant$raw_folder"

cd "$path"
ls | grep .dat > filenames.txt
file="filenames.txt"

lines=`cat $directory$participant$raw_folder$file`
ind=0
for line in $lines;
do
	rawFile_array[$ind]="$directory$participant$raw_folder$line"
	((ind=ind+1))
done

export MATLABPATH=/data/pt_02199/scripts

for raw in ${rawFile_array[@]}
do        
       MATLAB --version 9.7 matlab -nodisplay -nodesktop -nosplash -r "recon_corr_varadaptive('$raw', '$participant',40,10000,4);exit;"
done
cd "/data/pt_02199/scripts"
# 
