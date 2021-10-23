%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This code serves to look into navigator validation
% - plotting the traces is summarized in nav_validation_plots.m

%% Important for coil channels
% most interesting channels (closest to the lungs) are: 
% anterior channels: 17, 22, 3, 8; posterior channels: 32, 28, 13, 9
%
% (head vertex: posterior: 29, 25, 16, 12;  anterior: 20, 24, 1, 5)

%% Important for validation with biopac
% only 5 subjects have biopac info
% 08088b3, 286633c, 1228809, 1988356, 2615341, 2912194'


%% I selected 2615341 participant for plotting (index 9)
%% I selected channel 13 or 28 for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('/data/pt_02199/images_filtered_navs/image-recon/mapVBVD');
addpath('/data/pt_02199/scripts/XPACEtools/XPACEfileIO_tools');
addpath('/data/pt_02199/scripts');
TR = 0.0275; %s

channel_selected = 13; 

nav_dir = '/data/pt_02199/images_filtered_navs';
motion_dir = '/data/pt_02199/motion_tracking/';
biopac_dir = '/data/pt_02199/biopac/';
output_dir = '/data/pt_02199/plots/';
%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load the created structure containing all the traces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(output_dir)
load('traces.mat', 'Subject')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot the traces separately
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for kk = 9:length(participant{1})
    % plot biopac traces
    time = [0:length(Subject(kk).traces.respiration.triggers)/4-1] * TR;
    figure 
    subplot(2,2,1)
    plot(time, Subject(kk).traces.respiration.data(Subject(kk).traces.respiration.triggers(1:length(Subject(kk).traces.respiration.triggers)/4),1))
    xlabel('time [s]')
    ylabel('Respiration belt trace')
    subplot(2,2,2)
    plot(time, Subject(kk).traces.respiration.data(Subject(kk).traces.respiration.triggers(length(Subject(kk).traces.respiration.triggers)/4+1:2*length(Subject(kk).traces.respiration.triggers)/4),1))
    xlabel('time [s]')
    ylabel('Respiration belt trace')
    subplot(2,2,3)
    plot(time, Subject(kk).traces.respiration.data(Subject(kk).traces.respiration.triggers(2*length(Subject(kk).traces.respiration.triggers)/4+1:3*length(Subject(kk).traces.respiration.triggers)/4),1))
    xlabel('time [s]')
    ylabel('Respiration belt trace')
    subplot(2,2,4)
    plot(time, Subject(kk).traces.respiration.data(Subject(kk).traces.respiration.triggers(3*length(Subject(kk).traces.respiration.triggers)/4+1:4*length(Subject(kk).traces.respiration.triggers)/4),1))
    xlabel('time [s]')
    ylabel('Respiration belt trace')
end



for kk = [3,8,9,12]%length(participant{1})
    % plot navigators
    time = [0:length(Subject(kk).traces.dF0)-1] * TR;
    figure 
    subplot(2,2,1)
    plot(time, squeeze(Subject(kk).traces.dF0(1,channel_selected,:)))
    xlabel('time [s]')
    ylabel('dF0 [Hz]')
    subplot(2,2,2)
    plot(time, squeeze(Subject(kk).traces.dF0(2,channel_selected,:)))
    xlabel('time [s]')
    ylabel('dF0 [Hz]')
    subplot(2,2,3)
    plot(time, squeeze(Subject(kk).traces.dF0(3,channel_selected,:)))
    xlabel('time [s]')
    ylabel('dF0 [Hz]')
    subplot(2,2,4)
    plot(time, squeeze(Subject(kk).traces.dF0(4,channel_selected,:)))
    xlabel('time [s]')
    ylabel('dF0 [Hz]')
    suptitle(Subject(kk).name)
end


for kk = 9:9%:length(participant{1})
    % plot translational motion
    time = [0:length(Subject(kk).traces.motion(1).x)-1] * TR;
    figure 
    subplot(2,2,1)
    plot(time, Subject(kk).traces.motion(1).x, time, Subject(kk).traces.motion(1).y, time, Subject(kk).traces.motion(1).z)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    subplot(2,2,2)
    plot(time, Subject(kk).traces.motion(2).x, time, Subject(kk).traces.motion(2).y, time, Subject(kk).traces.motion(2).z)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    subplot(2,2,3)
    plot(time, Subject(kk).traces.motion(3).x, time, Subject(kk).traces.motion(3).y, time, Subject(kk).traces.motion(3).z)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    subplot(2,2,4)
    plot(time, Subject(kk).traces.motion(4).x, time, Subject(kk).traces.motion(4).y, time, Subject(kk).traces.motion(4).z)
    xlabel('time [s]')
    ylabel('Displacement [m]')
end

for kk = 9:9% length(participant{1})
    % plot rotational motion 
    
    % based on: DrawXpaceLogs_KPv1
    % preallocation for speed
    Rx = zeros(length(Subject(kk).traces.motion(1).Rx));
    Ry = zeros(length(Subject(kk).traces.motion(1).Ry));
    Rz = zeros(length(Subject(kk).traces.motion(1).Rz));
   
    for ind = 1:length(Subject(kk).traces.motion(1).x)
        x = exp(1i.*(Subject(kk).traces.motion(1).Rx(ind)*pi/180));
        y = exp(1i.*(Subject(kk).traces.motion(1).Ry(ind)*pi/180));
        z = exp(1i.*(Subject(kk).traces.motion(1).Rz(ind)*pi/180));
        Rx(ind) = (angle(x) * 180/pi);
        Ry(ind) = (angle(y) * 180/pi);
        Rz(ind) = (angle(z) * 180/pi);
    end
    
    time = [0:length(Subject(kk).traces.motion(1).x)-1] * TR;
    figure 
    subplot(2,2,1)
    plot(time, Rx, time, Ry, time, Rz)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    plot(time, Subject(kk).traces.motion(2).Rx, time, Subject(kk).traces.motion(2).Ry, time, Subject(kk).traces.motion(2).Rz)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    subplot(2,2,3)
    plot(time, Subject(kk).traces.motion(3).Rx, time, Subject(kk).traces.motion(3).Ry, time, Subject(kk).traces.motion(3).Rz)
    xlabel('time [s]')
    ylabel('Displacement [mm]')
    subplot(2,2,4)
    plot(time, Subject(kk).traces.motion(4).Rx, time, Subject(kk).traces.motion(4).Ry, time, Subject(kk).traces.motion(4).Rz)
    xlabel('time [s]')
    ylabel('Displacement [m]')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot the traces all together
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
measurement = 3;
channel_selected = 28; 

for kk = 1:1%1:length(participant{1})
    time = [0:length(Subject(kk).traces.motion(measurement).x)-1] * TR;
    slice = (1:length(time));
    %slice = (14800:15600); %(14780:15400); %(14050:15050);
    % based on: DrawXpaceLogs_KPv1
    % preallocation for speed
    Rx = zeros(1,length(slice));
    Ry = zeros(1,length(slice));
    Rz = zeros(1,length(slice));
   
    for ind = slice(1):slice(end)
        x = exp(1i.*(Subject(kk).traces.motion(measurement).Rx(ind)*pi/180));
        y = exp(1i.*(Subject(kk).traces.motion(measurement).Ry(ind)*pi/180));
        z = exp(1i.*(Subject(kk).traces.motion(measurement).Rz(ind)*pi/180));
        Rx(1,(1+ind-slice(1))) = (angle(x) * 180/pi);
        Ry(1,(1+ind-slice(1))) = (angle(y) * 180/pi);
        Rz(1,(1+ind-slice(1))) = (angle(z) * 180/pi);
    end
    
    figure
    [ha, pos] = tight_subplot(4,1,[0 .03],[.1 .01],[.1 .05])
    
    % plot respiration trace
%     axes(ha(1)) 
%     y4 = Subject(kk).traces.respiration.data(Subject(kk).traces.respiration.triggers(1:length(Subject(kk).traces.respiration.triggers)/4),1)';
%     plot(time(slice), y4(slice), 'LineWidth', 2, 'color', rgb('DimGray'))
%     yt = yticks;
%     set(ha(1),'YTick',yt(2:end));
%     ylabel('Respiration [a.u.]');
 
    % plot navigator trace
    axes(ha(2))
    y3 = vertcat(zeros(199,1), squeeze(Subject(kk).traces.dF0(measurement,channel_selected,:)))'./10;
    plot(time(slice), y3(slice), 'LineWidth', 2, 'color', rgb('DarkOrange'))
    ylabel('\DeltaF0 [Hz]');
    yt = yticks;
    set(ha(2),'YTick',yt(2:end));

    % plot translation trace
    axes(ha(3))
    plot(time(slice), Subject(kk).traces.motion(measurement).x(slice), 'color', rgb('DarkCyan'),'LineWidth', 2)
    hold on 
    plot(time(slice), Subject(kk).traces.motion(measurement).y(slice), 'color', rgb('SteelBlue'),'LineWidth', 2)
    hold on 
    plot(time(slice), Subject(kk).traces.motion(measurement).z(slice), 'color', rgb('SeaGreen'),'LineWidth', 2)
    ylabel({'Displacement','[mm]'});
    yt = yticks;
    set(ha(3),'YTick',yt(2:end));
    
%    text(405.8, -0.1 ,'X', 'color', rgb('DarkCyan'));
%    text(405.8, 0.35 ,'Y', 'color', rgb('SteelBlue'));
%    text(405.8, -0.4 ,'Z', 'color', rgb('SeaGreen'));
    
    
    % plot rotation trace
    axes(ha(4))
    plot(time(slice), Rx(1,:), 'color', rgb('Purple'),'LineWidth', 2)
    hold on 
    plot(time(slice), Ry(1,:), 'color', rgb('Violet'),'LineWidth', 2)
    hold on 
    plot(time(slice), Rz(1,:), 'color', rgb('Amethyst'), 'LineWidth', 2)
    ylabel('Rotations [{\circ}]');
    yt = yticks;
    %set(ha(4),'YTick',yt(2:end));

%    text(405.7, -0.06 ,'R_{X}', 'color', rgb('Purple'));
%    text(405.7, -0.12, 'R_{Z}', 'color', rgb('Violet'));
%    text(405.7, 0.008 ,'R_{Y}', 'color', rgb('Amethyst'));
    
    
    
    xlabel('Time [s]');
  
    set(ha(1:3),'XTickLabel',[]);
    
    suptitle(Subject(kk).name)

    hold off
end