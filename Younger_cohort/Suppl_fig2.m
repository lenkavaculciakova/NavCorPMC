% creating supplementary figure 2
% the XPACE tools used in this code for reading in the motion logs
% are a part of XPACE libraries for prospective motion correction system
addpath('/data/pt_02199/scripts/XPACEtools/XPACEfileIO_tools');
addpath('/data/pt_02199/scripts/XPACEtools/');
addpath('/data/pt_02199/scripts/')

path = '/data/pt_02199/motion_tracking/';

particip = {'2803151'};
log_num = [452, 453]; % 452 - pdw pmcOFF; 453 - pdw pmcON;

num_meas = length(log_num)/length(particip);

M = zeros(length(particip), num_meas);

% moton traces:
for log = 0: (num_meas-1)

    logs = DispXpaceLog(fullfile(path , particip{1}, '/', strcat('xpace_', num2str(log_num(1, 1)+log), '.log'))); 
    for ii =  1:(length(logs.x)) % based on Todd N et al. 2015
        dt = 27.5;   %TR in msec
        % calculate the rate of the motion
        S(ii) = sqrt((logs.x(ii))^2 + (logs.y(ii))^2+(logs.z(ii))^2+(logs.Rx(ii))^2+(logs.Ry(ii))^2+(logs.Rz(ii))^2);
         % calculate integrated motion metric
        M(log+1) = sum(S(ii)*dt); 
        % close created figures
        close all
        % calculate geometric displacement to combine translational traces
        % into one for a supplementary figure
        Geom_displacement(log+1, ii) =  sqrt((logs.x(ii))^2 + (logs.y(ii))^2+(logs.z(ii))^2);       
    end
end    
    
% navigator traces
navs = load('/data/pt_02199/plots/2803151/navigators/extracted_dF0.mat');
 

figure
% time starts with dummies (-198:0)
x_axis = [-198:(length(navs.dF0))]*dt/1000/60; % time in minutes

ax1 = subplot('Position', [0.15 0.73 0.8 0.2])

% selecting coil in inferior position  3,31, 8, 
navigator = vertcat(squeeze(zeros(199,1)), squeeze(navs.dF0(2,14,:)));
plot(x_axis, navigator, 'Color', [1 0.45 0])
xlim([-198*dt/1000/60, 18.1]);
ylim([-8, 4])
ylabel('\Deltaf0 [Hz]')
xlabel('Time [min]')
set(ax1,'FontSize',12)
set(ax1,'xticklabel',{[]})
linkaxes([ax1,ax2],'x')
title('   PMC off',  'FontSize', 16);
ax1.TitleHorizontalAlignment = 'left';

ax2 = subplot('Position', [0.15 0.55 0.8 0.18])
plot(x_axis, Geom_displacement(1,:), 'Color',[0.001 0.55 0.55])
xlim([-198*dt/1000/60, 18.1]);
ylabel({'Euclidean' ; 'displacement' ; '[mm]'});
ylim([-0.1, 1.3])
xlabel('Time [min]')
set(ax2,'FontSize',12)

% selecting coil 22 - anterior inferior position 
ax3 = subplot('Position', [0.15 0.26 0.8 0.2])
navigator = vertcat(squeeze(zeros(199,1)), squeeze(navs.dF0(3,22,:)));
plot(x_axis, navigator, 'Color', [1 0.45 0])
xlim([-198*dt/1000/60, 18.1]);
ylim([-3, 8]);
ylabel('\Deltaf0 [Hz]')
set(ax3,'FontSize',12)
title('   PMC on',  'FontSize', 16);
set(ax3,'xticklabel',{[]})
ax3.TitleHorizontalAlignment = 'left';


ax4 = subplot('Position', [0.15 0.08 0.8 0.18])
plot(x_axis, Geom_displacement(2,:), 'Color',[0.001 0.55 0.55])
xlim([-198*dt/1000/60, 18.1]);
ylabel({'Euclidean' ; 'displacement' ; '[mm]'});
ylim([-0.4, 1.4]);
xlabel('Time [min]')
set(ax4,'FontSize',12)

linkaxes([ax3, ax4],'x')
