%-----------------------------------------------------------------------
% Job saved on 24-Nov-2020 23:03:06 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% Average the echoes before registration using 'average_echoes.m' script
function []=subtract_maps(input_sess1, input_sess2, outpath, suffix)
    addpath('/data/pt_02133/1-scripts/spm12');

    [in1_path,in1_name, in1_ext]=fileparts(input_sess1);

    [in2_path,in2_name, in2_ext]=fileparts(input_sess2);
    
    [out_path,out_name, out_ext]=fileparts(outpath);
        
    in_files{1,1} = fullfile(in1_path, strcat(in1_name,in1_ext,',1'));
    in_files{2,1} = fullfile(in2_path, strcat(in2_name,in2_ext,',1'));
    
    matlabbatch{1}.spm.util.imcalc.input = in_files;
    matlabbatch{1}.spm.util.imcalc.output = strcat(in1_name,suffix);
    matlabbatch{1}.spm.util.imcalc.outdir = {out_path};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1-i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

    spm_jobman('run',matlabbatch);
    
end











