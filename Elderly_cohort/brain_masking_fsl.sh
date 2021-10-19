#!/bin/bash
# The code uses FSL to create and apply brain mask on parameter maps
directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/incoming/"
# select commented folders for second half or participants
subj_folders="subj_folders.txt" # "subj_folders2.txt"
maps_folders="maps_folders.txt" # "maps_folders2.txt"

declare -a correction=("uncorrected/pdw_01/" "f0-corrected_unwrap/pdw_02/")

dir_back="../"

lines=`cat $directory$subj_folders`
ind=0
for line in $lines;
do
	subj_folder_array[$ind]="$data_folder$line"
	subj_array[$ind]="$line"
	((ind=ind+1))
done

lines=`cat $directory$maps_folders`
ind=0
for line in $lines;
do
	maps_folder_array[$ind]="$data_folder$dir_back$line"
	maps_array[$ind]="$line"
	((ind=ind+1))
done

for correction in "${correction[@]}";
do
    for ind in 0 1 2 3 4;
    do
        #creating a mask
        
        folder="$data_folder${subj_array[$ind]}$correction"
        cd $folder
        for img1 in 20*_01_Magnitude.nii;
        do
            pdw1=$folder$img1
        done

        FSL bet $pdw1 $pdw1 -f 0.4 -m -n
        gunzip ${pdw1%.nii}_mask.nii.gz
        
        # masking the maps
        maps="${maps_folder_array[$ind]}"; 
        path=$maps${correction%pdw_02/}'Results/'
        cd $path
        for map in 20*.nii;
        do
            FSL fslmaths ${pdw1%.nii}_mask -mul $path$map $path${map%.nii}_FSLmasked.nii
            gunzip $path${map%.nii}_FSLmasked.nii.gz
        done
        
        # masking the error maps
        path=$maps${correction%pdw_02/}'Results/Supplementary/'
        cd $path
        for err_map in 20*_error.nii;
        do
            FSL fslmaths ${pdw1%.nii}_mask -mul $path$err_map $path${err_map%.nii}_FSLmasked.nii
            gunzip $path${err_map%.nii}_FSLmasked.nii.gz
        done
        for err_map in 20*_errorESTATICS.nii;
        do
            FSL fslmaths ${pdw1%.nii}_mask -mul $path$err_map $path${err_map%.nii}_FSLmasked.nii
            gunzip $path${err_map%.nii}_FSLmasked.nii.gz
        done

        
    done
done
    

