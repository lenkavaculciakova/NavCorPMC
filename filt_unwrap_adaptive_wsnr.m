function phi = filt_unwrap_adaptive_wsnr(ct, SNR, SNR_thresh, wsmooth, wSNR)
% phi = filt_unwrap_adaptive(ct, SNR, SNR_thresh, wsmooth)
% Adaptive filter function estimates phi from a complex-valued scalar time-series.
% For low SNR time points the complex value is weighted toward the value of
% the highly smoothed time course. The first time point is set to zero.
% 
% Input:
% ct = complex-valued time-series
% SNR = SNR estimate for each time point in time-series
% SNR_thresh = threshold at which weighting toward smoothed time course is
% significantly increased
% wsmooth = window size of cosine filter used for creating smoothed
% time-course
%
% Output:
% phi = filtered and unwrapped time-series of phase of complex-valued signal
% 
% N. Weiskopf, MPI-CBS, 1/8/20

%% Adapted to allow variable size of the window for snr 
% wSNR = 1/2 window size for SNR window used in combination of smooth
% time-series 


% estimate highly smoothed time-series using a simple cosine filter
% and a simple implementation of forward/backwards filtering
b=cos(((0:wsmooth)-wsmooth/2)/wsmooth*pi);
b=b/sum(b);
a=1;
fct_smooth = nw_filtfilt(b,a,ct);

% adaptively combine values from time-series and smoothed time-series
ct_combined=zeros(1,length(ct));
weight=zeros(1,length(ct));
ct_combined(1)=ct(1);

for nr = 2:length(ct)    
    A=1;
    % dealing with the edges
    if (nr < (wSNR+1))
        weight(nr)=(min(SNR(1:(2*wSNR+1)))/SNR_thresh)^4; 
    elseif (nr > (length(ct)-wSNR))
        weight(nr)=(min(SNR((length(ct)-2*wSNR-1):(length(ct))))/SNR_thresh)^4; 
    else  
        weight(nr)=(min(SNR((nr-wSNR):(nr+wSNR)))/SNR_thresh)^4;
        ct_combined(nr) = (A*fct_smooth(nr) + weight(nr)*ct(nr))/(A+weight(nr));
    end
end

% using instantaneous phase calculation for estimating unwrapped
% phase time-series
phi_combined=zeros(1,length(ct));
dphi_combined=zeros(1,length(ct));
phi(1) = 0;
for nr = 2:length(ct)
   dphi_combined(nr) = angle(ct_combined(nr)*conj(ct_combined(nr-1)));
   phi_combined(nr) = phi_combined(nr-1)+dphi_combined(nr); 
end

phi=phi_combined;

