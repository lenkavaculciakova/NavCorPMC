%-----------------------------------------------------------------------
% Job saved on 24-Nov-2020 23:03:06 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% Average the echoes before registration using 'average_echoes.m' script
function []=brain_extraction_job(input, mask, suffix)
    addpath('/data/pt_02133/1-scripts/spm12');

    [in_path,in_name, in_ext]=fileparts(input);

    [msk_path,msk_name, msk_ext]=fileparts(mask);

    in_files{1,1} = fullfile(in_path, strcat(in_name,in_ext,',1'));
    in_files{2,1} = fullfile(msk_path, strcat(msk_name,msk_ext,',1'));

    matlabbatch{1}.spm.util.imcalc.input = in_files;
    matlabbatch{1}.spm.util.imcalc.output = strcat(in_name,suffix);
    matlabbatch{1}.spm.util.imcalc.outdir = {in_path};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1.*i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

    spm_jobman('run',matlabbatch);
    
end











