#!/bin/bash

#######################################################################################################
#		                      Correct for GNL using HCP tool                                  # 
#######################################################################################################

# Enable FSL 5.0.9 (only works with this version)
# Assumed input file format: *.nii 

# Script adapted from 'cbs_gradunwarp.sh' created by Dr. Luke J. Edwards using the HCP tool for gradient non-linearity correction 
# Change to the directory of the script folder 
PATH_SCRIPT=/data/pt_gr_weiskopf_coreg2017/1-scripts/gradnonlin
cd $PATH_SCRIPT

GUPATH=$PATH_SCRIPT/gradunwarp.git

export PATH=$PATH:$GUPATH/bin
export PYTHONPATH=$PYTHONPATH:$GUPATH/lib/python2.7/site-packages

######################################## COMMAND INPUTS: START ########################################
# Input and output entries
IN_NAME=$1
IN_PATH=$2
OUT_PATH=$3
COEFFS=$4

# Create output directory if non-existent 
mkdir -p $OUT_PATH
######################################## COMMAND INPUTS: END ##########################################

########################################## FUNCTION: START ############################################
echo '%%%%%%%%%%%%%%%%%%%%%%%%%%% CORRECTING FOR GRADIENT NONLINEARITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
# Correct input image for gradient non-linearity 
IN=`echo $IN_PATH/$IN_NAME`
IN_BASE=`basename ${IN%.*}`       	# Input basename ("%" looks for anything before "*" - "#" looks for naything after "*")
OUT=$OUT_PATH/${IN_BASE}_gnl.nii   	# GNL corrected image
WARP=$OUT_PATH/${IN_BASE}_warp.nii 	# GNL warp 

echo $IN
echo $IN_BASE
echo $OUT 

# Note that Jacobian modulation (is not) applied! 
# (Jac modulation doesn't seem to be applied even without specifying the --nojacobian option?)
FSL ./GradientDistortionUnwarp.sh --workingdir=$OUT_PATH/wd --coeffs=$COEFFS --in=$IN --out=$OUT --owarp=$WARP # --nojacob

# Calculate gradent deviations
GRADDEV=$OUT_PATH/grad_dev.nii 
GRADDEV_X=$OUT_PATH/grad_dev_x.nii
GRADDEV_Y=$OUT_PATH/grad_dev_y.nii
GRADDEV_Z=$OUT_PATH/grad_dev_z.nii
IMRM=$OUT_PATH/grad_dev_?	

# Based on:
# https://github.com/Washington-University/HCPpipelines/blob/master/DiffusionPreprocessing/scripts/eddy_postproc.sh
FSL calc_grad_perc_dev --fullwarp=$WARP -o $GRADDEV
FSL fslmerge -t $GRADDEV $GRADDEV_X $GRADDEV_Y $GRADDEV_Z
FSL fslmaths $GRADDEV -div 100 $GRADDEV # Convert from % deviation to absolute
FSL imrm $IMRM

########################################## FUNCTION: END #############################################
