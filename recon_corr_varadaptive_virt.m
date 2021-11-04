function recon_corr_varadaptive_virt(rawfile, rawfolder, snrthr, wsmooth, wsnr)
    %   ARGUMETNS:
    %       rawfile  - path to twix raw data file (.dat)
    %       rawfilename - text file that contains raw data file names
    % has to be set before tempname/tepmdir is called the first time
    % setenv('TMPDIR', '/run/user/13040');
    % disp(['tempname test: ' tempname]);
    % Original code by Kornelius Podranski, modifief by Vaculciakova
    % Add paths
    
    % original location of this script
    addpath('/data/pt_02133/1-scripts/navigators/')
    % original location of the reconstructon code
    addpath('/data/pt_02133/1-scripts/navigators/image-recon-kpodranski');
    % mapVBVD is necessary for reading in the raw data, see more in NAVCor.m script
    addpath('/data/pt_02133/1-scripts/navigators/image-recon-kpodranski/mapVBVD');
    % in-house reconstrunction code uses SPM12
    addpath('/data/pt_02133/1-scripts/spm12/');
    
    directory = '/data/pt_02133/incoming';

    filename = strcat('f0-corrected_varadapt_virt');
    outroot = fullfile(directory, rawfolder,'/../',filename);

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
   
                    
