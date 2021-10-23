% First extract all the navigators and save them in a structure using the
% recon code containing 'save' function

addpath('/data/pt_02199/scripts');

datapath = '/data/pt_02199/images_filtered_navs/';

output = '/data/pt_02199/results/fitting/';

%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);

correction= {'f0-corrected_varadapt_virt'};
TR = 27.5; %ms   % oxford protocol: 28.5ms
TEnav = 19.022; %ms     % oxford protocol: 19.442 ms

% channels positioned most inferior and superior
inferior = [3,8,9,13,17,22,28,32];
superior = [1,5,12,16,20,24,25,29];
coils = [inferior, superior];

SNRthr = 40;
No_of_fits = 20;    % ends up fitting about 15% of the trace 

median_coeff_b = zeros(length(participant{1}), 4, length(coils),1);
median_coeff_k = zeros(length(participant{1}), 4, length(coils),1);

%generate data
for subject = 1:length(participant{1})
    tic
    nav_path = char(fullfile(datapath, participant{1}{subject}, 'raw'));
    file_nav = fopen(char(fullfile(nav_path,'filenames.txt')),'r');
    formatSpec = '%s \n';
    filenames = textscan(file_nav, formatSpec);
    fclose(file_nav);
    for raw = 1:length(filenames{1})
        % create a path where dPhi traces are saved
        path = fullfile(nav_path, '/../', correction, filenames{1}{raw}(1:end-4), '/')
        cd(path{1})
        % load the traces
%         dPhi = load('dPhi.mat');
%         dPhi_cpx = load('dPhi_cpx.mat');
%         dPhi_adapt = load('dPhi_adapt.mat');
        dPhi_virt = load('dPhi_virt.mat');
        SNRperTimePoint = load('SNRperTimePoint.mat');
        
        for channel = 1:length(coils) 
            % select 50 starting points of intervals to fit randomly 
            x = [0:size(dPhi_virt.dPhi_virt,2)-1]*TR/1000; 
            trace = dPhi_virt.dPhi_virt(channel,:);
            
            coeff_b = [];
            coeff_k = [];
            counter = 0;
            % go through the intervals one by one and fit the traces
            while ((length(coeff_b) < No_of_fits))
                initial_interval_value = randi([1, size(dPhi_virt.dPhi_virt,2)-300]);
                % sections for fitting are always 300 points long
                section = initial_interval_value+[1:300];
                % select only such sections that do not suffer from low SNR
                if (sum(SNRperTimePoint.SNRperTimePoint(coils(channel),section)<SNRthr) <= 15) % less than 5% of the points is low snr
                    x_short = x(section);
                    curve = dPhi_virt.dPhi_virt(channel,section);
                    % fitting small sections of the traces
                    [fitresult, gof] = createFits(x_short, curve, x, trace);
                    % extract R^2 
                    [local_gof_sin, local_gof_lin] = gof.rsquare; %takes the first value corresponding to the sin fit
                    if (local_gof_sin > 0.5)
                        coeffs_1 = coeffvalues(fitresult{1,1});
                        coeff_b = [coeff_b,abs(coeffs_1(2))];            
                    end
                    if (local_gof_lin > 0.5)
                        coeffs_2 = coeffvalues(fitresult{2,1});
                        coeff_k = [coeff_k,coeffs_2(2)];            
                    end

                end
                counter = counter +1;   
                if (counter == 200)
                    coeff_b = [coeff_b,nan]
                    coeff_k = [coeff_k,nan]; 
                    break
                end               
            end           
            median_coeff_b(subject, raw, channel,:) = median(coeff_b, 'omitnan');
            median_coeff_k(subject, raw, channel,:) = median(coeff_k, 'omitnan');            
        end
    end
    toc
end

% analyze
peak_to_peak = zeros(length(participant{1}),1);
baseline = zeros(length(participant{1}),1);

for subject = 1:length(participant{1})
    % extract median value from measurements
    for raw = 1:length(filenames{1})
        b_coefficients = nonzeros(squeeze(median_coeff_b(subject,raw,:,:)));
        k_coefficients = nonzeros(squeeze(median_coeff_k(subject,raw,:,:)));
        b_per_measurement(raw) = median(b_coefficients, 'omitnan');
        k_per_measurement(raw) = median(k_coefficients, 'omitnan');
    end 
    % compute mean over the measurements
    peak_to_peak(subject) = 2 * mean(b_per_measurement) / (2 * pi * TEnav/1000)
    baseline(subject) = x(end) * mean(k_per_measurement) / (2 * pi * TEnav/1000)
end

cd '/data/pt_02199/results/fitting/'

save('peak_to_peak','peak_to_peak');
save('baseline', 'baseline');
