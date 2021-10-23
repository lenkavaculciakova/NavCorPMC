%-----------------------------------------------------------------------
% Job saved on 07-Nov-2020 11:58:03 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%% Average the echoes before registration using 'average_echoes.m' script
addpath('/data/pt_02133/1-scripts/spm12');
spm_dir = '/data/pt_02133/1-scripts/spm12';

data_path = '/data/pt_02133/incoming/';

particip_folder = {'s001/s001_7T_20191128_MR1/','s004/s004_7T_20191216_MR1/', ...
    's005/s005_7T_20191216_MR1/', 's006/s006_7T_20191218_MR1/', ...
    's007/s007_7T_20200120_MR1/','s008/s008_7T_20200122_MR1/resources/', ...
    's009/s009_7T_20200310_MR1/','s010/s010_7T_20200210_MR1/', ...
    's011/s011_7T_20200203_MR1/','s012/s012_7T_20200225_MR1/'};

correction= {'uncorrected', 'f0-corrected_varadapt_virt'};%'f0-corrected_unwrap'

reference_folder = 'pdw_01/';
source_folder = 'pdw_02/';

maps_path = '/data/pt_02133/';
maps_folder = {'sub-s001/FMRIB/s001_7T_20191128_MR2/anat/MPMs_nav/', ...
    'sub-s004/FMRIB/s004_7T_20191216_MR2/anat/MPMs_nav/', 'sub-s005/FMRIB/s005_7T_20191216_MR2/anat/MPMs_nav/', ...
    'sub-s006/FMRIB/s006_7T_20191218_MR2/anat/MPMs_nav/', 'sub-s007/FMRIB/s007_7T_20200120_MR2/anat/MPMs_nav/', ...
    'sub-s008/FMRIB/s008_7T_20200122_MR2/anat/MPMs_nav/', 'sub-s009/FMRIB/s009_7T_20200311_MR2/anat/MPMs_nav/', ...
    'sub-s010/FMRIB/s010_7T_20200211_MR2/anat/MPMs_nav/',  'sub-s011/FMRIB/s011_7T_20200203_MR2/anat/MPMs_nav/', ...
    'sub-s012/FMRIB/s012_7T_20200225_MR2/anat/MPMs_nav/'};
 
for index = 1:10 %- number of participants * 2 registering only uncorrected maps
    refpath = fullfile(data_path, particip_folder{index},correction{1}, reference_folder);
    sourcepath = fullfile(data_path, particip_folder{index},correction{1}, source_folder);
    
    % identify reference pdw image
    cd(refpath)
    Ref_nii_avg = dir('new_for_spm_magn_average_for_registration_gnl.nii');
    kk=1;
    while kk< (length(Ref_nii_avg)+1)
           Reference_avg = fullfile(refpath, Ref_nii_avg(kk).name);
           kk=kk+1;
    end
    
    % identify source pdw image
    cd(sourcepath)
    Source_nii_avg = dir('new_for_spm_magn_average_for_registration_gnl.nii');
    kk=1;
    while kk< (length(Source_nii_avg)+1)
           Source_avg = fullfile(sourcepath, Source_nii_avg(kk).name);
           kk=kk+1;
    end
    
    counter = 0;
    for corr = correction
        
        mapspath = fullfile(maps_path, maps_folder{index}, corr,'Results/');
  
        % identify 'other images' - in this case it is PD, R1 and R2* maps
        cd(mapspath{1})
        Maps_dir = dir('20*');
        Maps_dir = Maps_dir(~endsWith({Maps_dir.name},{'.nii', '.json', '.nii.gz'}));

        cd(fullfile(mapspath{1}, 'Supplementary'));
        Suppl_dir = dir('20*');
        Suppl_dir = Suppl_dir(~endsWith({Suppl_dir.name},{'.nii','.json', '.nii.gz'}));

        kk = 1;
        while kk<(length(Maps_dir)+1)
            Maps_nii = fullfile(Maps_dir(kk).folder, Maps_dir(kk).name, strcat(Maps_dir(kk).name, '_gnl_cp.nii.gz'));
            Maps_nii = gunzip(Maps_nii);
            Maps{kk+(counter*8),1}= strcat(Maps_nii{1}, ',1'); % We have 3 maps and 5 error maps - therefore 8
            kk=kk+1;
        end

        ll=1;
        while ll<(length(Suppl_dir)+1)
               Suppl_nii = fullfile(Suppl_dir(ll).folder, Suppl_dir(ll).name, strcat(Suppl_dir(ll).name, '_gnl_cp.nii.gz'));
               Suppl_nii = gunzip(Suppl_nii);
               Maps{kk-1+ll+(counter*8),1} = strcat(Suppl_nii{1}, ',1');
               ll=ll+1;
        end
        counter = counter + 1;
    end

    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {Reference_avg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {Source_avg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = Maps;
    
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2 1 0.5];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'spm_r';
    
    spm_jobman('run',matlabbatch);

end
