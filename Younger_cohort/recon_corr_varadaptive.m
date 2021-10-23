function recon_corr_varadaptive(rawfile, participant, snrthr, wsmooth, wsnr)
    %   ARGUMETNS:
    %       rawfile  - path to twix raw data file (.dat)
    %       rawfilename - text file that contains raw data file names
    % has to be set before tempname/tepmdir is called the first time
    %setenv('TMPDIR', '/run/user/13040');
    %disp(['tempname test: ' tempname]);
    % Originally by Kornelius Podranski, modified by L. Vaculciakova
    % Add paths
    
    addpath('/data/pt_02199/scripts')
    addpath('/data/pt_02199/scripts/image-recon-kpodranski');
    addpath('/data/pt_02199/scripts/image-recon-kpodranski/mapVBVD');
    addpath('/data/pt_02199/plots');
    addpath('/data/pt_02133/1-scripts/spm12/');
    
    directory = '/data/pt_02199/images_filtered_navs';

    filename = strcat('f0-corrected_varadapt_virt');
    outroot = fullfile(directory, participant, filename);

    if ~exist(outroot, 'dir')
        mkdir(outroot)
    end
 
    % parallel processing
    nProcs = 20;
    
    %% Run recon for each dataset
    pp = check_start_parpool(nProcs);

    % f0 corrected recon
    ReconFLASH_v6_EcoNav_varadaptive_virt(rawfile, ...
                        [], ...
                       'f0Correct', true, ...
                       'f0Complex',true, ...
                       'sweep_adapt_params', true,...
                       'adapt_snrthr', snrthr,...
                       'adapt_wsmooth', wsmooth,...
                       'adapt_wsnr', wsnr,...
                       'virt_coil', true,...
                       'outRoot', outroot);

    clearvars('twixObj');
    
    %% cleanup
    delete_parpool(pp);

    exit
end
   
                    
