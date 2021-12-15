addpath('/data/pt_02199/scripts');

path='/data/pt_02199/images_filtered_navs';
participants={'08088b3', '1228809', '1548408', '1941787', '1941787_2', ...
    '1988356', '2615341', '2691136', '2803151', '2912194', '286633c'};
correction = 'f0-corrected_varadapt_virt';

channels = 32;
percentage = zeros(length(participants), 4, channels); % 4 = number of measurements

threshold = 40;

for subject = 1:length(participants)
    datadir = fullfile(path, participants{subject}, correction);
    cd(datadir)
    measurements = dir('2019*'); measurements = [measurements, dir('meas*')];
    for meas = 1:length(measurements)
        pointSNR = load(fullfile(measurements(meas).folder, measurements(meas).name, 'SNRperTimePoint.mat'));
        len_lowSNR = sum(pointSNR.SNRperTimePoint < threshold,2)';
        full_length = size(pointSNR.SNRperTimePoint,2);
        percentage(subject, meas, :) = len_lowSNR./full_length.*100;         
    end  
end

mean(percentage, 'all')
std(percentage(:))

young_perc = percentage;
save('Young_perc.mat', 'young_perc')