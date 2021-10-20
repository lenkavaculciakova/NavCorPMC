function [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(chdat, SNR_thresh, wsmooth,wsnr)
% function [phi, SNR, min_SNR] =  nw_nav_calc_adaptive(chdat, SNR_thresh, wsmooth)
% Estimate phi from time-series of truncated navigator data of as single
% channel. Uses adaptive filtering based on time point SNR estimates.
% first time point is set to zero
% Input:
% chdat = single channel of complex-valued turncated navigator data
% (ADC_samples x nr_of_TR)
% SNR_thresh = threshold at which weighting toward smoothed time course is
% significantly increased
% wsmooth = window size of cosine filter used for creating smoothed
% time-course
% 
% Output:
% phi = filtered and unwrapped time-series of phase of complex-valued signal 
% SNR = SNR estimate for each time point of unfiltered time series
% min_SNR = robust minimal SNR across time-series (from 1% percentile)
%
% N. Weiskopf, MPI-CBS, 1/8/20

do_plot = 0; % output diagnostic plots

if nargin < 3
    wsmooth = [];
end
if isempty(wsmooth)
    wsmooth = 10000; % heuristic large filtering window for artifact-free time series
end

if nargin < 2
    SNR_thresh = [];
end
if isempty(SNR_thresh)
    SNR_thresh = 40; % for our typical navigators SNR < 50 indicates issues
end

% average ADC time points (complex-valued)
% empirically it appears as if last 30:50 ADC points are most stable
%use_ADC=30:50;
sum_chdat = median(chdat(:,:),1);

% estimate SNR per time point from magnitude (unsmoothed)
SNR = mean(abs(chdat(:,:)),1)./std(abs(chdat(:,:)),[],1);

% adaptively filter time-series based on SNR per time point
phi = filt_unwrap_adaptive_wsnr(sum_chdat, SNR, SNR_thresh, wsmooth,wsnr);

% some helpful diagnostic plots
if do_plot==1
    figure;
    plot(filt_unwrap(sum_chdat, []),'g'); % unfiltered for comparison
    hold
    plot(phi,'r'); % filtered time course
    plot(filt_unwrap(sum_chdat, wsmooth),'k'); 
    %plot(SNR/10+10,'b'); % SNR diagnostics
    legend('Unfiltered Phase (rad)', 'Filtered Phase (rad)', 'Highly smoothed phase (rad)', 'SNR/10+10')
    hold off
end

min_SNR=nw_percentile(SNR,2,1);


