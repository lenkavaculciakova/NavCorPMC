% computing the percentage of traces with low SNR (below threshold)
addpath('/data/pt_02133/1-scripts/navigators/');

path='/data/pt_02133/incoming';
participants={'s001', 's004', 's005', 's006', 's007', ...
    's008', 's009', 's010', 's011', 's012'};
correction = 'f0-corrected_varadapt_virt';

outpath = '/data/pt_02133/2-tests/navigators/';

channels = 32;
percentage = zeros(length(participants), 4, channels); % 4 = number of measurements


for subject = 1:length(participants)
    datadir = fullfile(path, participants{subject});
    cd(datadir)
    session = dir('*_7T_*MR1');
    if subject == 6
        datadir = fullfile(path, participants{subject}, session.name,'resources', correction);
    else       
        datadir = fullfile(path, participants{subject}, session.name, correction);
    end
    cd(datadir)
    measurements = dir('20*'); measurements = [measurements, dir('meas*')];
    for meas = 1:length(measurements)
        pointSNR = load(fullfile(measurements(meas).folder, measurements(meas).name, 'SNRperTimePoint.mat'));
        if (subject == 1 && meas ==3) || (subject == 6 && meas == 3)
            threshold = 60;
        else
            threshold = 40;
        end
        len_lowSNR = sum(pointSNR.SNRperTimePoint < threshold,2)';
        full_length = size(pointSNR.SNRperTimePoint,2);
        percentage(subject, meas, :) = len_lowSNR./full_length.*100;         
    end  
end

mean(percentage, 'all')
std(percentage(:))

mean_perc_across_ch = mean(percentage, 3);

cd(outpath)
elderly_perc = percentage;
save('Elderly_perc.mat', 'elderly_perc')
