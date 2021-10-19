#!/bin/bash

directory='/data/pt_02133/1-scripts/navigators/'
# input directory
data_folder="/data/pt_02133/incoming/"
# select "subj_folders2.txt" for second half of participants
subj_folders="subj_folders.txt" #"subj_folders2.txt"

declare -a folders_cor=("f0-corrected_varadapt_virt/pdw_01/" "f0-corrected_varadapt_virt/pdw_02/")  

# output directory
out_dir="/data/pt_02133/2-tests/navigators/scan-rescan/"
dir_back="../"

lines=`cat $directory$subj_folders`
ind=0
for line in $lines;
do
	subj_folder_array[$ind]="$data_folder$line"
	subj_array[$ind]="$line"
	((ind=ind+1))
done
for ind in 5 6 7 8 9;
do  
    subjects[$ind-5]="${subj_array[$ind]}"
done

for ind in 0 1 2 3 4;  
do
    INPUT_NAME="magn_average_for_registration.nii"
    INPUT_PATH=("$data_folder${subj_array[$ind]}${folders_cor[0]}" "$data_folder${subj_array[$ind]}${folders_cor[1]}")
    OUT_PATH=("$out_dir${subjects[$ind]}${folders_cor[0]}" "$out_dir${subjects[$ind]}${folders_cor[1]}")
    FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE="/data/pt_02133/1-scripts/gradnonlin/SHfiles/7t_coeff.grad"
    
    for session in 0 1;
    do 
        mkdir -p ${OUT_PATH[$session]}
        ./DoGNL.sh $INPUT_NAME ${INPUT_PATH[$session]} ${OUT_PATH[$session]} $FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE
    done
done
        
        
