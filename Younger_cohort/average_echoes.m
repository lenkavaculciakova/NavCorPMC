addpath('/data/pt_02133/1-scripts/spm12');
spm_dir = '/data/pt_02133/1-scripts/spm12';

data_path = '/data/pt_02199/images_filtered_navs/';

%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);

correction= {'f0-corrected_varadapt_virt' 'uncorrected_varadapt_all'};

source_folder = {'pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav/', 'pdw_pmcON_kp_mtflash3d_v1c_mpmnav/',...
    't1w_pmcOFF_kp_mtflash3d_v1c_mpmnav/','t1w_pmcON_kp_mtflash3d_v1c_mpmnav/'};

for index = 1:length(participant{1})
    for contrast = 1:length(source_folder)
        for corr = 1:length(correction)
            sourcepath = fullfile(data_path, participant{1}{index},correction{corr}, source_folder{contrast});

            % identify source images
            cd(sourcepath)
            Source_nii = dir('*_Magnitude.nii');
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
