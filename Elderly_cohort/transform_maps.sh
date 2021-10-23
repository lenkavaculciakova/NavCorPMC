#!/bin/bash

directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/incoming/"
maps_folders="maps_folders.txt"

#output directory
out_dir="/data/pt_02133/2-tests/navigators/scan-rescan/"
dir_back="../"

lines=`cat $directory$maps_folders`
ind=0
for line in $lines;
do
	maps_folder_array[$ind]="$data_folder$dir_back$line"
	maps_array[$ind]="$line"
	((ind=ind+1))
done

ind=0
for ind in 5 6 7 8 9;
do  
    subjects[$ind-5]="${maps_array[$ind]}"
done


# Applying the transform matrix to the maps
for idx in 0 1 2 3 4;
do
    subject="${subjects[$idx]}"
    # uncorrected
    maps="${maps_folder_array[$idx]}"; 
    path=$maps'uncorrected/Results/'
    cd $path
    dirlist=($(ls -d 20*/))
    for map in ${dirlist[@]};
    do  
        gunzip $path$map${map%/}_gnl.nii.gz
        FSL flirt -in $path$map${map%/}_gnl.nii -ref $path$map${map%/}_gnl.nii -applyxfm -init $out_dir$subject'uncorrected/gnl_pdw2_2_pdw1_uncor_dof6_cs5_fs1.mat' -out $path$map${map%/}_FSLregistered_dof6_cs5_fs1.nii
        gunzip $path$map${map%/}_FSLregistered_dof6_cs5_fs1.nii.gz
    done
    path=$maps'uncorrected/Results/Supplementary/'
    cd $path
    dirlist=($(ls -d 20*/))
    for err_map in ${dirlist[@]};
    do
        gunzip $path$err_map${err_map%/}_gnl.nii.gz
        FSL flirt -in $path$err_map${err_map%/}_gnl.nii -ref $path$err_map${err_map%/}_gnl.nii -applyxfm -init $out_dir$subject'uncorrected/gnl_pdw2_2_pdw1_uncor_dof6_cs5_fs1.mat' -out $path$err_map${err_map%/}_FSLregistered_dof6_cs5_fs1.nii
        gunzip $path$err_map${err_map%/}_FSLregistered_dof6_cs5_fs1.nii.gz
    done
               
    # f0-corrected
    path=$maps'f0-corrected_unwrap/Results/'
    cd $path
    dirlist=($(ls -d 20*/))
    for map in ${dirlist[@]};
    do
        gunzip $path$map${map%/}_gnl.nii.gz
        FSL flirt -in $path$map${map%/}_gnl.nii -ref $path$map${map%/}_gnl.nii -applyxfm -init $out_dir$subject'uncorrected/gnl_pdw2_2_pdw1_uncor_dof6_cs5_fs1.mat' -out $path$map${map%/}_FSLregistered_dof6_cs5_fs1.nii
        gunzip $path$map${map%/}_FSLregistered_dof6_cs5_fs1.nii.gz
    done
    
    path=$maps'f0-corrected_unwrap/Results/Supplementary/'
    cd $path
    dirlist=($(ls -d 20*/))
    for err_map in ${dirlist[@]};
    do
        gunzip $path$err_map${err_map%/}_gnl.nii.gz
        FSL flirt -in $path$err_map${err_map%/}_gnl.nii -ref $path$err_map${err_map%/}_gnl.nii -applyxfm -init $out_dir$subject'uncorrected/gnl_pdw2_2_pdw1_uncor_dof6_cs5_fs1.mat' -out $path$err_map${err_map%/}_FSLregistered_dof6_cs5_fs1.nii
        gunzip $path$err_map${err_map%/}_FSLregistered_dof6_cs5_fs1.nii.gz
    done
    
    ((idx=idx+1))         
done

 
cd $directory
#
