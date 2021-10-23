#!/bin/bash
cd "/data/pt_02199/scripts"
directory="/data/pt_02199/images_filtered_navs/"
participant="08088b3" # select participant code from participant_list.txt

declare -a folders_cor=("uncorrected_varadapt_all/pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav/" "uncorrected_varadapt_all/pdw_pmcON_kp_mtflash3d_v1c_mpmnav/" "f0-corrected_varadapt_virt/pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav/" "f0-corrected_varadapt_virt/pdw_pmcON_kp_mtflash3d_v1c_mpmnav/" "f0-corrected_varadapt_all/pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav/" "f0-corrected_varadapt_all/pdw_pmcON_kp_mtflash3d_v1c_mpmnav/")  


# output directory
out_dir="/data/pt_02199/scan-rescan/"
dir_back="../"

for ind in 0 1 2 3 4 5;  
do
    INPUT_NAME="magn_average_for_registration.nii"
    INPUT_PATH="$directory$participant"/"${folders_cor[ind]}"
    OUT_PATH="$out_dir$participant"/"${folders_cor[ind]}"
    FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE="/data/pt_02133/1-scripts/gradnonlin/SHfiles/7t_coeff.grad"
    
    echo mkdir -p $OUT_PATH
    echo ./DoGNL.sh $INPUT_NAME ${INPUT_PATH[$session]} ${OUT_PATH[$session]} $FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE

	echo gunzip $OUT_PATH"magn_average_for_registration_gnl.nii.gz"
	echo cp $OUT_PATH"magn_average_for_registration_gnl.nii" $INPUT_PATH
done


#!/bin/bash
cd "/data/pt_02199/scripts"     
directory="/data/pt_02199/maps_filtered_navs/"

declare -a folders_cor=("uncorrected_varadapt_all/pmcOFF/" "uncorrected_varadapt_all/pmcON/" "f0-corrected_varadapt_virt/pmcOFF/" "f0-corrected_varadapt_virt/pmcON/" "f0-corrected_varadapt_all/pmcOFF/" "f0-corrected_varadapt_all/pmcON/")  

for ind in 0 1 2 3 4 5;  
do
	path=$directory$participant${folders_cor[ind]}'/Results/'
	cd $path

	for map in 20*_PD.nii 20*_R1.nii 20*_R2s_WOLS.nii
	do
		INPUT_NAME=$map
	    INPUT_PATH=$path
	    mkdir -p $path${map%.nii}
	    OUT_PATH=$path${map%.nii}
	    FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE="/data/pt_02133/1-scripts/gradnonlin/SHfiles/7t_coeff.grad"
	    cd $directory
	    ./DoGNL.sh $INPUT_NAME $INPUT_PATH $OUT_PATH $FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE
		echo gunzip $OUT_PATH"20*_gnl.nii.gz"
		echo cp $OUT_PATH"20*_gnl.nii" $OUT_PATH"20*_gnl_cp.nii"
	done
	path=$directory$participant$cor'/Results/Supplementary/'
	cd $path	
	
	for err_map in 20*_PDparam_error.nii 20*_T1param_error.nii 20*_PDw_errorESTATICS.nii 20*_R2s_errorESTATICS.nii 20*_T1w_errorESTATICS.nii
	do
	    INPUT_NAME=$err_map
	    INPUT_PATH=$path
	    mkdir -p $path${err_map%.nii}
	    OUT_PATH=$path${err_map%.nii}
	    FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE="/data/pt_02133/1-scripts/gradnonlin/SHfiles/7t_coeff.grad"
	    cd $directory
	    ./DoGNL.sh $INPUT_NAME $INPUT_PATH $OUT_PATH $FULL_PATH_TO_GRADIENT_COEFFICIENT_FILE
		echo gunzip $OUT_PATH"20*_gnl.nii.gz"
		echo cp $OUT_PATH"20*_gnl.nii" $OUT_PATH"20*_gnl_cp.nii"
	done
done
