#!/bin/bash

directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/incoming/"
# select the commented text files (!in order), separated due to parallelization

# !!! change line 43
# mask name if subj_folders.txt selected: for_spm_magn_average_for_registration_gnl_mask.nii
# mask name if subj_folders2.txt selected: magn_average_for_registration_gnl_mask.nii
subj_folders="subj_folders.txt" #"subj_folders.txt" "subj_folders2.txt" "subj_folders2.txt"
maps_folders="maps_folders.txt" #"maps_folders_b.txt" "maps_folders_2b.txt" "maps_folders2.txt"

declare -a corrections=("f0-corrected_varadapt_virt/pdw_01/" "f0-corrected_varadapt_all/pdw_01/") # "f0-corrected_unwrap/pdw_01/"


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

for ind in 0 1 2 3 4; #
do
    #creating or loading a mask
        
    folder="$data_folder${subj_array[$ind]}uncorrected/pdw_01/"
    cd $folder
    for img1 in for_spm_magn_average_for_registration_gnl_mask.nii;
    do
        pdw1=$folder$img1
    done

#     FSL bet $pdw1 $pdw1 -f 0.4 -m -n
#     gunzip -f ${pdw1%.nii}_mask.nii.gz
        
    for correction in "${corrections[@]}";
    do
        # masking the maps
        maps="${maps_folder_array[$ind]}"; 
        path=$maps${correction%pdw_01/}'Results/'
        cd $path
        for map in 20*PD.nii 20*R1.nii 20*R2s_WOLS.nii;
        do
#            if [[ -e $path${map%.nii}/${map%.nii}_gnl_cp.nii ]]; then 
#                mv $path${map%.nii}/${map%.nii}_gnl_cp.nii $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg.nii
#            fi
#             if [[ ! -e $path${map%.nii}/${map%.nii}_gnl_cp.nii ]]; then 
#                 cp $path${map%.nii}/${map%.nii}_gnl_cp.nii.gz $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg.nii.gz
#                 gunzip -f $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg.nii.gz
#             fi
 
#           FSL fslmaths $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg -mul ${pdw1%.nii}_mask $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg_brain.nii
 #           gunzip $path${map%.nii}/${map%.nii}_gnl_cp_spm_coreg_brain.nii.gz
            matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${map%.nii}/spm_r${map%.nii}_gnl_cp.nii', '$pdw1', '_brain'); exit"
        done
        
#         # masking the error maps
#         path=$maps${correction%pdw_01/}'Results/Supplementary/'
#         cd $path
#         for err_map in 20*_error.nii;
#         do
#             if [[ -e $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii ]]; then 
#                 mv $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii
#             fi
# #             if [[ ! -e $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii ]]; then 
# #                 mv $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii.gz $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii.gz
# #                 gunzip -f $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii.gz
# #             fi
# #            FSL fslmaths $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii -mul ${pdw1%.nii}_mask $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg_brain.nii
# #            gunzip $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg_brain.nii.gz
#             matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii', '$pdw1', '_brain'); exit"
#         done
#         for err_map in 20*_errorESTATICS.nii;
#         do
#             if [[ -e $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii ]]; then 
#                 mv $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii
#             fi
# #             if [[ ! -e $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii ]]; then 
# #                 mv $path${err_map%.nii}/${err_map%.nii}_gnl_cp.nii.gz $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii.gz
# #                 gunzip -f $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii.gz
# #             fi
# #            FSL fslmaths $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii -mul ${pdw1%.nii}_mask $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg_brain.nii
# #            gunzip $path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg_brain.nii.gz
#             matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); brain_extraction_job('$path${err_map%.nii}/${err_map%.nii}_gnl_cp_spm_coreg.nii', '$pdw1', '_brain'); exit"
#         done       
     done
done
    

