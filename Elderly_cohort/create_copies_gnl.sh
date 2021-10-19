#!/bin/bash

# copies of files after applying gradient nonlinearity correction in order to avoid rewriting files by SPM, that requires write access 

directory="/data/pt_02133/1-scripts/navigators/"
cd $directory
data_folder="/data/pt_02133/"
maps_folders="maps_folders2.txt" #"maps_folders2.txt" "maps_folders_b.txt" "maps_folders_2b.txt"
subj_folders="subj_folders2.txt" #"subj_folders.txt"

dir_back="../"
out_path="/data/pt_02133/2-tests/navigators/grad_nonlin_cor/"
weighted_path="2-tests/navigators/scan-rescan/"

correction=( "f0-corrected_varadapt_all" "f0-corrected_varadapt_virt" "uncorrected") #"f0-corrected_varadapt_all" "uncorrected"

lines=`cat $directory$maps_folders`
ind=0
for line in $lines;
do
	maps_folder_array[$ind]="$data_folder$line"
	maps_array[$ind]="$line"
	((ind=ind+1))
done

lines=`cat $directory$subj_folders`
ind=0
for line in $lines;
do
	subj_folder_array[$ind]="$data_folder$line"
	subj_array[$ind]="$line"
	((ind=ind+1))
done

ind=0
for ind in 5 6 7 8 9;
do  
    subjects[$ind-5]="${subj_array[$ind]}"
done


for ind in 0 1 2 3 4;
do
    for cor in ${correction[@]};
    do        
        
        in_path="$data_folder${maps_array[$ind]}$cor/Results/"
        cd $in_path
        
        dirlist=($(ls -d 20*/))
        for map in ${dirlist[@]};
        do
            file=$in_path$map${map%/}_gnl.nii.gz
            cp $file $in_path$map${map%/}_gnl_cp.nii.gz
            cp $file $out_path${subjects[$ind]}$cor/session2/${map%/}_gnl.nii.gz           
        done
        
        in_path2="$data_folder${maps_array[$ind]}$cor/Results/Supplementary/"
        cd $in_path2
        
        dirlist2=($(ls -d 20*/))
        for err_map in ${dirlist2[@]};
        do
            file=$in_path2$err_map${err_map%/}_gnl.nii.gz
            cp $file $in_path2$err_map${err_map%/}_gnl_cp.nii.gz
            cp $file $out_path${subjects[$ind]}$cor/session2/${err_map%/}_gnl.nii.gz           
        done
        

#        in_path3="$data_folder$weighted_path${subjects[$ind]}$cor/pdw_01/"
#        cd $in_path3
     
#        filelist3=($(ls magn*_gnl.nii.gz))
#        for img in ${filelist3[@]};
#        do
#            file=$img
#            cp $in_path3"$file" $in_path3"new_for_spm_$file"
#            cp $in_path3"new_for_spm_$file" $data_folder"incoming/"${subj_array[$ind]}$cor"/pdw_01/"
#            cp $file $out_path${subjects[$ind]}$cor/session2/${map%/}_gnl.nii.gz           
#            gunzip $data_folder"incoming/"${subj_array[$ind]}$cor"/pdw_01/new_for_spm_"$file
#        done
        
#        in_path4="$data_folder$weighted_path${subjects[$ind]}$cor/pdw_02/"
#        cd $in_path4
#        filelist4=($(ls magn*_gnl.nii.gz))
#        for img in ${filelist4[@]};
#        do
#            file=$img
#            cp $in_path4"$file" $in_path4"new_for_spm_$file"
#            cp $in_path4"new_for_spm_$file" $data_folder"incoming/"${subj_array[$ind]}$cor"/pdw_02/"
#            gunzip $data_folder"incoming/"${subj_array[$ind]}$cor"/pdw_02/new_for_spm_"$file
#            cp $file $out_path${subjects[$ind]}$cor/session2/${map%/}_gnl.nii.gz           
 #      done
    done
done
