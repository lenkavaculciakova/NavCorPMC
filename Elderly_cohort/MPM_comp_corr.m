%-----------------------------------------------------------------------
% Job saved on 15-Dec-2019 17:55:37 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% 
addpath('/data/pt_02133/1-scripts/spm12');
spm_dir = '/data/pt_02133/1-scripts/spm12';

data_path = '/data/pt_02133/incoming/';

participant = {'s001', 's004', 's005','s006', 's007', 's008','s009','s010', 's011','s012'}; %   
particip_folder = {'s001_7T_20191128_MR1','s004_7T_20191216_MR1','s005_7T_20191216_MR1', 's006_7T_20191218_MR1',... %
     's007_7T_20200120_MR1', 's008_7T_20200122_MR1', 's009_7T_20200310_MR1','s010_7T_20200210_MR1','s011_7T_20200203_MR1','s012_7T_20200225_MR1'};%

repetition={'_01','_02'};%'_01', '_02'

B0B1_location={'s001_7T_20191128_MR2', 's004_7T_20191216_MR2', 's005_7T_20191216_MR2', 's006_7T_20191218_MR2',... % ,
    's007_7T_20200120_MR2','s008_7T_20200122_MR2','s009_7T_20200311_MR2','s010_7T_20200211_MR2','s011_7T_20200203_MR2','s012_7T_20200225_MR2'} % 

folder = 'f0-corrected_varadapt_all';

for rep = 1:length(repetition)
    for ii = 1:length(participant)
        if (strcmp(repetition{rep},'_01'))
            datadir = fullfile(data_path,participant{ii}, particip_folder{ii});
            cd(datadir);
        elseif (strcmp(repetition{rep},'_02'))
            datadir = fullfile(data_path,participant{ii}, B0B1_location{ii});
            cd(datadir);
        end
           
        output_folder = fullfile('/data/pt_02133/', strcat('sub-',participant{ii}),'FMRIB', particip_folder{ii},'anat', 'MPMs_nav',folder);
 
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
        
        datadir = fullfile(data_path,participant{ii}, particip_folder{ii});
        cd(datadir);
       
        % identify pdw magnitude images
        cd(fullfile(datadir, folder,strcat('pdw',repetition{rep})))
        PDw_nii = dir('20*Magnitude.nii');
        kk=1;
        while kk<(length(PDw_nii)+1)
               PDw{kk,1} = (fullfile(datadir, folder,strcat('pdw',repetition{rep}), PDw_nii(kk).name));
               kk=kk+1;
        end
        % identify t1w magnitude images
        cd(fullfile(datadir, folder,strcat('t1w',repetition{rep})))
        T1w_nii = dir('20*Magnitude.nii');
        kk=1;
        while kk<(length(T1w_nii)+1)
               T1w{kk,1} = (fullfile(datadir,  folder,strcat('t1w',repetition{rep}), T1w_nii(kk).name));
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
        matlabbatch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised = {'/data/pt_02133/1-scripts/hMRI-CBS-toolbox.git/config/local/hmri_CBS_7T_defaults.m'};
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.output.outdir = {output_folder};
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_us = '-';

        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b1input = B1;
        %%
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b0input = B0;
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_EPI.b1parameters.b1defaults = {'/data/pt_02133/1-scripts/hMRI-CBS-toolbox.git/config/local/hmri_b1_CBS_7T_defaults.m'};
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.MT = '';
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.PD = PDw;
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.T1 = T1w;
        matlabbatch{2}.spm.tools.hmri.create_mpm.subj.popup = false;
        spm_jobman('run',matlabbatch)
    end
end