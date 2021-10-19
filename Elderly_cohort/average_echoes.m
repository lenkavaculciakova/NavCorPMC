%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The code average_echoes.m loads 6 niftis corresponding to 6 echoes from 
%% multi-echo flash acquisition and creates an average using SPM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Adjustable parameters
addpath('/data/pt_02133/1-scripts/spm12');
spm_dir = '/data/pt_02133/1-scripts/spm12';

data_path = '/data/pt_02133/incoming/';

particip_folder = {'s001/s001_7T_20191128_MR1/',...
    's004/s004_7T_20191216_MR1/','s005/s005_7T_20191216_MR1/', ...
    's006/s006_7T_20191218_MR1/','s007/s007_7T_20200120_MR1/', ...
    's008/s008_7T_20200122_MR1/resources/','s009/s009_7T_20200310_MR1/', ...
    's010/s010_7T_20200210_MR1/','s011/s011_7T_20200203_MR1/', ...
    's012/s012_7T_20200225_MR1/'};

correction= {'uncorrected', 'f0-corrected_varadapt_virt'};
source_folder = {'pdw_01/', 'pdw_02/', 't1w_01/','t1w_02/'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main loop
for index = 1:length(particip_folder)
    for contrast = 1:length(source_folder)
        for corr = 1:length(correction)
            sourcepath = fullfile(data_path, particip_folder{index},correction{corr}, source_folder{contrast});

            % identify source images
            cd(sourcepath)
            Source_nii = dir('20*_Magnitude.nii');
            Source_nii = Source_nii(~startsWith({Source_nii.name},'spm_r')); 
            Source_nii = Source_nii(~endsWith({Source_nii.name},'07_Magnitude.nii'));
            kk=1;
            while kk< (length(Source_nii)+1)
                   Source{kk,1} = strcat(fullfile(sourcepath, Source_nii(kk).name),',1');
                   kk=kk+1;
            end

            matlabbatch{1}.spm.util.imcalc.input = Source;
            matlabbatch{1}.spm.util.imcalc.output = 'magn_average_for_registration';
            matlabbatch{1}.spm.util.imcalc.outdir = {sourcepath};
            matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3+i4+i5+i6)/6';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 16;  

            spm_jobman('run',matlabbatch);
            
            fclose all;
            copyfile(fullfile(sourcepath, strcat('magn_average_for_registration','.nii')),...
                fullfile(sourcepath, strcat('for_spm_magn_average_for_registration','.nii')),'f')

        end
    end   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
