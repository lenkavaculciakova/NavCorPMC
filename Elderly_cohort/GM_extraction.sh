#!/bin/bash

directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/incoming/"
subj_folders="subj_folders.txt"
maps_folders_MR1="maps_folders_b.txt"
maps_folders_MR2="maps_folders.txt"

declare -a corrections=("uncorrected/pdw_01/")  #"f0-corrected_varadapt_all/pdw_01/" "f0-corrected_varadapt_virt/pdw_01/"

dir_back="../"


lines=`cat $directory$subj_folders`
ind=0
for line in $lines;
do
	subj_folder_array[$ind]="$data_folder$line"
	subj_array[$ind]="$line"
	((ind=ind+1))
done

lines=`cat $directory$maps_folders_MR1`
ind=0
for line in $lines;
do
	maps_folder_array_MR1[$ind]="$data_folder$dir_back$line"
	maps_array_MR1[$ind]="$line"
	((ind=ind+1))
done

lines=`cat $directory$maps_folders_MR2`
ind=0
for line in $lines;
do
	maps_folder_array_MR2[$ind]="$data_folder$dir_back$line"
	maps_array_MR2[$ind]="$line"
	((ind=ind+1))
done

for ind in 0 1 2 3 4; #
do
    # load a WM mask
    
    folder="${maps_folder_array_MR1[$ind]}uncorrected/MPMCalc/"
    cd $folder
    for dirs in ls -d -- c120*/;
    do
        GMmask_folder=$dirs
    done
    GMmask=$folder$GMmask_folder${GMmask_folder%/}"_gnl_cp_replace_val_replace_val_er2.nii"
        
    for correction in "${corrections[@]}";
    do
        # masking the maps session 1
        maps="${maps_folder_array_MR1[$ind]}"; 
        path=$maps${correction%pdw_01/}'Results/'
        cd $path
        for map in 20*PD.nii 20*R1.nii 20*R2s_WOLS.nii;
        do
            matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${map%.nii}/${map%.nii}_gnl_cp.nii', '$GMmask', '_GM'); exit"
        done
#        # masking the error maps session 1
#        path=$maps${correction%pdw_01/}'Results/Supplementary/'
#        cd $path
#        for err_map in 20*_PDparam_error.nii 20*_T1param_error.nii 20*_PDw_errorESTATICS.nii 20*_R2s_errorESTATICS.nii 20*_T1w_errorESTATICS.nii;
#        do
#           matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii', '$WMmask', '_WM'); exit"
#        done
        # masking the maps session 2
        maps="${maps_folder_array_MR2[$ind]}"; 
        path=$maps${correction%pdw_01/}'Results/'
        cd $path
        for map in 20*PD.nii 20*R1.nii 20*R2s_WOLS.nii;
        do
            matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${map%.nii}/spm_r${map%.nii}_gnl_cp.nii', '$GMmask', '_GM'); exit"
        done
        
#        # masking the error maps session 2
#        path=$maps${correction%pdw_01/}'Results/Supplementary/'
#        cd $path
#        for err_map in 20*_PDparam_error.nii 20*_T1param_error.nii 20*_PDw_errorESTATICS.nii 20*_R2s_errorESTATICS.nii 20*_T1w_errorESTATICS.nii;
#        do
#           matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii', '$WMmask', '_WM'); exit"
#        done
    done
done
        
        
        
