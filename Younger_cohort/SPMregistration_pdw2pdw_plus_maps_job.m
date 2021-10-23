%-----------------------------------------------------------------------
% Job saved on 07-Nov-2020 11:58:03 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%% Average the echoes before registration using 'average_echoes.m' script
addpath('/data/pt_02199/scripts');
addpath('/data/pt_02133/1-scripts/spm12');
spm_dir = '/data/pt_02133/1-scripts/spm12';

data_path = '/data/pt_02199/images_filtered_navs/';

%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);
correction= {'uncorrected_varadapt_all', 'f0-corrected_varadapt_virt'};

reference_folder = 'pdw_pmcOFF_kp_mtflash3d_v1c_mpmnav/';
source_folder = 'pdw_pmcON_kp_mtflash3d_v1c_mpmnav/';

maps_path = '/data/pt_02199/maps_filtered_navs/';
 
for index = 1:length(participant{1}) %- number of participants * 2 registering only uncorrected maps
    refpath = fullfile(data_path, participant{1}{index},correction{1}, reference_folder);
    sourcepath = fullfile(data_path, participant{1}{index},correction{1}, source_folder);
    
    % identify reference pdw image
    cd(refpath)
    Ref_nii_avg = dir('for_spm_magn_average_for_registration_gnl.nii');
    kk=1;
    while kk< (length(Ref_nii_avg)+1)
           Reference_avg = fullfile(refpath, Ref_nii_avg(kk).name);
           kk=kk+1;
    end
    
    % identify source pdw image
    cd(sourcepath)
    Source_nii_avg = dir('for_spm_magn_average_for_registration_gnl.nii');
    kk=1;
    while kk< (length(Source_nii_avg)+1)
           Source_avg = fullfile(sourcepath, Source_nii_avg(kk).name);
           kk=kk+1;
    end
    
    counter = 0;
    for corr = correction      
        mapspath = fullfile(maps_path, participant{1}{index}, corr);
  
        % identify 'other images' - in this case it is PD, R1 and R2* maps
        cd(fullfile(mapspath{1},'pmcON/Results/'))
        Maps_dir = dir('20*');
        Maps_dir = Maps_dir(~endsWith({Maps_dir.name},{'.nii', '.json', '.nii.gz'}));

        cd(fullfile(mapspath{1}, 'pmcON/Results/Supplementary'));
        Suppl_dir = dir('20*');
        Suppl_dir = Suppl_dir(~endsWith({Suppl_dir.name},{'.nii','.json', '.nii.gz'}));

        kk = 1;
        while kk<(length(Maps_dir)+1)
            Maps_nii = fullfile(Maps_dir(kk).folder, Maps_dir(kk).name, strcat(Maps_dir(kk).name, '_gnl_cp.nii'));
            Maps{kk+(counter*8),1}= strcat(Maps_nii, ',1'); % We have 3 maps and 5 error maps - therefore 8
            kk=kk+1;
        end

        ll=1;
        while ll<(length(Suppl_dir)+1)
               Suppl_nii = fullfile(Suppl_dir(ll).folder, Suppl_dir(ll).name, strcat(Suppl_dir(ll).name, '_gnl_cp.nii'));
               Maps{kk-1+ll+(counter*8),1} = strcat(Suppl_nii, ',1');
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
