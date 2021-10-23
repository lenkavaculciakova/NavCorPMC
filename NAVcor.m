%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Navigator correction was a part of in-house reconstraction code originally 
% written by Martina F. Callaghan, further developed by Kerrin J Pine and 
% Kornelius Podranski. 
% Here, you will find only a section of the code concerned with the NAVcor
% itself and exporting plots. 
% You will need mapVBVD by Philipp Ehses to read in Siemens raw .dat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nav - parameter containing unsorted navigator traces read in using
% mapVBVD tool (sorting into img/ref is done later). The traces are 
% truncated down to points 301:330. These values were selected to remove
% signal contaminated by eddy currents from the beginning and spoiler at
% the end. 
%
% reconPars are parameters passed to the recon function called 
% 'ReconFLASH_v6_EcoNav_varadaptive_virt', which is not part of this 
% repository as a whole, but just the navigator correction. It is called 
% in scripts named recon_corr_varadaptive_virt.m or recon_uncor.m 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% working with complex data
% select a reference point of the navigator time-series. In this case, we
% opted for point number 10, but in principle it can be any. It is
% important that the point SNR is good. 
navRef = nav(:,:,10);

% compute phase angles
dPhi(:,:) = angle(median((nav(:,:,:)./navRef(:,:,1)),1)); %

dPhi_cpx(:,:) = dPhi(:,:); % created just for plotting

if reconPars.sweep_adapt_params
    adapt_wsmooth_success = [];
    adapt_wsnr_success = [];
    adapt_snrthr_success = [];
    increment = 200;
    for adapt_snrthr = [40,50,60]
        for adapt_wsnr = [4:25]
            for adapt_wsmooth = [10000:increment:length(dPhi(:,:))]
                trace_position = [];
                for channel=1:nCoils
                    [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(squeeze(nav(:,channel,:)),...
                    adapt_snrthr,adapt_wsmooth,adapt_wsnr);
                    dPhi(channel,:) =  phi;
                    if (max(phi) < 2*pi && min(phi) > -1.5*pi)
                        trace_position = [trace_position, 1];
                    end
                end
                if (sum(trace_position) == nCoils)
                    within_2pi = true; % meaning that the trace is not centered around 2pi, but very roughly round zero (if it were not for the drift)
                end

                [unwrap_fail, failed_win_pos, failed_win_pos_per_channel, movwin_size] = check_cpx_wrapping(dPhi(:,:), TR/1000, 1.5*pi);

                if (isempty(unwrap_fail) && within_2pi)
                    adapt_wsmooth_success = [adapt_wsmooth_success, adapt_wsmooth];
                    break;
                end
            end
            toc
            disp(['Sweeping parameters of adaptive smoothing: snrthr= ' num2str(adapt_snrthr) ' wsnr= ' num2str(adapt_wsnr) '...']);
            tic;

            if (~isempty(adapt_wsmooth_success))
                adapt_wsnr_success = [adapt_wsnr_success, adapt_wsnr];
                break;
            end
        end
        if (~isempty(adapt_wsmooth_success))
            adapt_snrthr_success = [adapt_snrthr_success, adapt_snrthr];
            break;
        end
    end
    if isempty(adapt_wsmooth_success) % use parameters passed in the recon since the sweep did not find a solution 
        for channel=1:nCoils
            [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(squeeze(nav(:,channel,:)),...
            reconPars.adapt_snrthr,reconPars.adapt_wsmooth,reconPars.adapt_wsnr);
            dPhi(channel,:) =  phi;
        end 
    else % use parameters found by the sweep
        for channel=1:nCoils
            [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(squeeze(nav(:,channel,:)),...
            adapt_snrthr_success,adapt_wsmooth_success,adapt_wsnr_success);
            dPhi(channel,:) =  phi;
        end 
    end
else % use parameters passed in the recon 
    for channel=1:nCoils
        [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(squeeze(nav(:,channel,:)),...
        reconPars.adapt_snrthr,reconPars.adapt_wsmooth,reconPars.adapt_wsnr);
        dPhi(channel,:) =  phi;
    end 
end

dPhi_adapt(:,:) = dPhi(:,:); % created just for plotting

if reconPars.virt_coil
    % look at the correlation coefficient in btw the smoothed channels
    for channel=1:nCoils
        dPhi_smoothed(channel,:) = movmean(dPhi(channel,:), TR.*1e-3*250); %smoothing 
    end
    Corr_coef_matrix = corrcoef(dPhi_smoothed(:,:)');
    % get the average correlation coef per channel
    mean_corr_coef = zeros(1,nCoils);
    for channel = 1:nCoils
        C_sorted = (sort(Corr_coef_matrix(channel,:),'ascend'));
        C_sorted(end) = []; % remove self-correlation as it would bias the mean of badly correlated channels 
        mean_corr_coef(channel) = mean(C_sorted);
    end
    % identify channels whose coefficient is <-1, 0.5) 
    % would not work if too many channels are random
    faulty_channels = find(mean_corr_coef < 0.5);
    mean_corr_coef
    if (length(faulty_channels) ~= nCoils)
        dPhi = virtual_coil_mean(dPhi, faulty_channels);
        toc
        disp(['Replacement of channels: ' num2str(faulty_channels) ' by mean virtual coil...']);
        tic;
    else
        toc
        disp(['All channels have low correlation - mean virtual coil was not applied.']);
        tic;
    end
end
dPhi_virt(:,:) = dPhi(:,:); % created just for plotting and export

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% uncomment if you want to export any navigator traces
% % for exporting:
% for channel=1:32
%     SNRperTimePoint(channel,:) = mean(abs(squeeze(nav(:,channel,:))),1)./std(abs(squeeze(nav(:,channel,:))),[],1);
% end
% 
% %plotting
% for j = 1:nCoils
%     %disp(j);
%     fig = figure('visible', 'off');
%     plot(squeeze(dPhi_cpx(j,:)), '--g')
%     hold on
%     %plot(squeeze(dPhi_adapt(j,:)), '--r')
%     %hold on
%     plot(squeeze(dPhi(j,:)), '--k')              
%     hold off
% 
%     if (~exist('adapt_wsmooth_success', 'var') || ( exist('adapt_wsmooth_success', 'var') && isempty(adapt_wsmooth_success)))
%         title(sprintf('Navigator Timecourses for Channel %d  ; default values snrthr = %d  wsmooth = %d wsnr = %d',...
%             j, reconPars.adapt_snrthr,reconPars.adapt_wsmooth,reconPars.adapt_wsnr));
%     else
%         title(sprintf('Navigator Timecourses for Channel %d  ; snrthr = %d  wsmooth = %d wsnr = %d',...
%             j, adapt_snrthr_success, adapt_wsmooth_success, adapt_wsnr_success));
%     end
%     xlabel('Meas');
%     ylabel('\Delta\Phi [rad]');
%     legend({'complex', 'cpx adapt'}, 'Location','northwest','Orientation','horizontal');
%     fig.PaperType = 'a4';
%     fig.PaperOrientation = 'landscape';
%     if ~exist(fullfile(reconPars.outRoot, reconPars.fileName , 'navigator_cpx_varadapt'),'dir')
%         mkdir(fullfile(reconPars.outRoot, reconPars.fileName , 'navigator_cpx_varadapt'));
%     end
% 
% 
%     print(fig, fullfile(reconPars.outRoot, reconPars.fileName , 'navigator_cpx_varadapt',...
%         sprintf('%s%02d%s', 'nav_ch', j, '.pdf')), '-dpdf', '-fillpage') ;   
%     savefig(fig, fullfile(reconPars.outRoot, reconPars.fileName , 'navigator_cpx_varadapt',...
%         sprintf('%s%02d%s', 'nav_ch', j, '.fig'))) ;   
% end
% 
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'nav.mat'), 'nav');           
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'dPhi.mat'), 'dPhi');
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'dPhi_cpx.mat'), 'dPhi_cpx');
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'dPhi_adapt.mat'), 'dPhi_adapt');
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'SNRperTimePoint.mat'), 'SNRperTimePoint');       
% save(fullfile(reconPars.outRoot, reconPars.fileName , 'dPhi_virt.mat'), 'dPhi_virt');
