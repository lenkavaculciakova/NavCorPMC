#!/bin/bash

directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/incoming/"
# select txt files with '2' for second half of participants
subj_folders="subj_folders.txt" #"subj_folders2.txt"
maps_folders_MR1="maps_folders_b.txt" # "maps_folders_2b.txt"
maps_folders_MR2="maps_folders.txt" # "maps_folders2.txt"

out_folder='/data/pt_02133/2-tests/navigators/scan-rescan/'

declare -a corrections=("uncorrected/pdw_01/") # "f0-corrected_varadapt_all/pdw_01/")  

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

ind=0
for ind in 5 6 7 8 9;
do  
    subjects[$ind-5]="${maps_array_MR2[$ind]}"
done

for ind in 0 1 2 3 4; # 
do
    for correction in "${corrections[@]}";
    do
        # masking the maps session 1
        maps_MR1="${maps_folder_array_MR1[$ind]}"; 
        maps_MR2="${maps_folder_array_MR2[$ind]}"; 
        path_MR1=$maps_MR1${correction%pdw_01/}'Results/'
        path_MR2=$maps_MR2${correction%pdw_01/}'Results/'
        path_err_MR1=$maps_MR1${correction%pdw_01/}'Results/Supplementary/'
        path_err_MR2=$maps_MR2${correction%pdw_01/}'Results/Supplementary/'
        
        cd $path_MR1
        counter=0
        for map in 20*PD.nii 20*R1.nii 20*R2s_WOLS.nii;
        do
            maps_sess1[$counter]=$map
            counter=$counter+1
        done
        
        cd $path_MR2
        counter=0
        for map in 20*PD.nii 20*R1.nii 20*R2s_WOLS.nii;
        do
            maps_sess2[$counter]=$map
            counter=$counter+1
        done
        for index in 0 1 2;
        do 
            matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); subtract_maps('$path_MR1${maps_sess1[$index]%.nii}/${maps_sess1[$index]%.nii}_gnl_cp_GM.nii', '$path_MR2${maps_sess2[$index]%.nii}/spm_r${maps_sess2[$index]%.nii}_gnl_cp_GM.nii' ,'$out_folder${subjects[ind]}${correction%pdw_01/}', '_diff'); exit"
        done

# following part deals with error maps

#         cd $path_err_MR1
#         counter=0
#         for map_err in 20*_PDparam_error.nii 20*_T1param_error.nii 20*_PDw_errorESTATICS.nii 20*_R2s_errorESTATICS.nii 20*_T1w_errorESTATICS.nii;
#         do
#             maps_err_sess1[$counter]=$map_err
#             counter=$counter+1
#         done
#         
#         cd $path_err_MR2
#         counter=0
#         for map_err in 20*_PDparam_error.nii 20*_T1param_error.nii 20*_PDw_errorESTATICS.nii 20*_R2s_errorESTATICS.nii 20*_T1w_errorESTATICS.nii;
#         do
#             maps_err_sess2[$counter]=$map_err
#             counter=$counter+1
#         done
#         for index in 0 1 2 3 4;
#         do 
#             matlab -nodesktop -nodisplay -r "cd('/data/pt_02133/1-scripts/navigators'); subtract_maps('$path_err_MR1${maps_err_sess1[$index]%.nii}/${maps_err_sess1[$index]%.nii}_gnl_cp_WM.nii', '$path_err_MR2${maps_err_sess2[$index]%.nii}/${maps_err_sess2[$index]%.nii}_gnl_cp_spm_coreg_WM.nii' ,'$out_folder${subjects[ind]}${correction%pdw_01/}', '_diff'); exit"
#         done
     done
done
        
        
