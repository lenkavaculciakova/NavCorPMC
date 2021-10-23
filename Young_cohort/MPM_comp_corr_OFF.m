%-----------------------------------------------------------------------
% Job saved on 15-Dec-2019 17:55:37 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% F0corrected and pmcOFF
addpath('/data/pt_02199/spm12');
%spm_dir = '/data/pt_02199/spm12';
spm_dir = '/data/pt_02133/1-scripts/spm12';


data_path = '/data/pt_02199/images_filtered_navs/';
%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);
folder = 'f0-corrected_varadapt_virt'

for ii = 1:length(participant{1})
    datadir = fullfile(data_path,participant{1}{ii});
    cd(datadir);
    output_folder = fullfile('/data/pt_02199/maps_filtered_navs',participant{1}{ii},folder,'pmcOFF');
    if ~exist(output_folder, 'dir')
       mkdir(output_folder)
    end

    % identify B0 mapping files    
    B0_dir = dir('*gre*');
    B0_dir2= cat(1,B0_dir(1).name,B0_dir.name);
    B0_nii = cat(1,dir(fullfile(B0_dir(1).name, '*nii')),dir(fullfile(B0_dir(2).name, '*nii'))); 
    kk=1;
    while kk<(length(B0_nii)+1)
           B0{kk,1} = (fullfile(datadir,B0_dir2(kk,:),B0_nii(kk).name));
           kk=kk+1;
    end
    % identify B1 mapping files    
    B1_dir = dir('*seste*');
    B1_nii = dir(fullfile(B1_dir.name, '*nii')); 
    kk=1;
    while kk<(length(B1_nii)+1)
           B1{kk,1} = (fullfile(datadir,B1_dir.name,B1_nii(kk).name));
           kk=kk+1;
    end
    % identify pdw magnitude images
    cd(fullfile(datadir, folder,'pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav'))
    PDw_nii = dir('*Mag*');
    kk=1;
    while kk<(length(PDw_nii)+1)
           PDw{kk,1} = (fullfile(datadir, folder,'pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav', PDw_nii(kk).name));
           kk=kk+1;
    end
    % identify t1w magnitude images
    cd(fullfile(datadir, folder,'t1w_pmcOFF_kp_mtflash3d_v1c_mpmnav'))
    T1w_nii = dir('*Mag*');
    kk=1;
    while kk<(length(T1w_nii)+1)
           T1w{kk,1} = (fullfile(datadir, folder,'t1w_pmcOFF_kp_mtflash3d_v1c_mpmnav', T1w_nii(kk).name));
           kk=kk+1;
    end
    %remove the 7th echo in case it is there to 
    if (length(PDw)>6)
        PDw(7) = [];
    end
    if (length(T1w)>6)
        T1w(7) = [];
    end
    % compute maps
    matlabbatch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised = {'/data/pt_02199/spm12/toolbox/hMRI-cbs/config/local/hmri_CBS_7T_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.output.outdir = {output_folder};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_us = '-';
    
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b1input = B1;
    %%
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b0input = B0;
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b1parameters.b1defaults = {'/data/pt_02199/spm12/toolbox/hMRI-cbs/config/local/hmri_b1_CBS_7T_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.MT = '';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.PD = PDw;
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.T1 = T1w;
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.popup = false;
    spm_jobman('run',matlabbatch)
end
