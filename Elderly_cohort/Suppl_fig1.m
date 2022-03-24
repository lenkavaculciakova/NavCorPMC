% plotting Supplementary figure 1
addpath('/data/pt_02133/1-scripts/navigators/');
%select dataset
datapath='/data/pt_02133/incoming/s008/s008_7T_20200122_MR1/resources/f0-corrected_varadapt_all/2020-01-22-111139/'
cd(datapath)

% select channel
channel = 18;

% set TR to convert x axis into minutes
TR = 0.0285; %sec

%load the traces
dPhi = load('dPhi.mat');
dPhi_cpx = load('dPhi_cpx.mat');
dPhi_adapt = load('dPhi_adapt.mat');
SNRperTimePoint = load('SNRperTimePoint.mat');

% prcent of the trace below SNR threshold:
threshold = 40;
sum(SNRperTimePoint.SNRperTimePoint(channel,:)<threshold) / ...
    length(SNRperTimePoint.SNRperTimePoint(channel,:)) *100

%plot the traces
figure
x = 1:length(dPhi.dPhi(1,:));
x = x.*TR./60; % converted to minutes

ax1 = subplot('Position', [0.15 0.73 0.8 0.2])
plot(x, dPhi_cpx.dPhi_cpx(channel, :),  'Color', [1 0.45 0])
xlim([x(1), x(end)])
ylabel('φ [rad]', 'FontSize', 14)
set(gca,'XTick',[]);


ax2 = subplot('Position', [0.15 0.53 0.8 0.2])
plot(x, SNRperTimePoint.SNRperTimePoint(channel,:), 'Color', [0,0,0]+0.5);
hold on
plot(x, ones(1,length(x)).* 40, 'Color', 'r')
hold off
ylabel('SNR', 'FontSize', 14)
xlim([x(1), x(end)])
set(gca,'XTick',[]);

ax3 = subplot('Position', [0.15 0.33 0.8 0.2])
plot(x,  unwrap(dPhi_cpx.dPhi_cpx(channel, :)),  'Color', [1 0.45 0])
xlim([x(1), x(end)])
ylabel('φ [rad]', 'FontSize', 14)
set(gca,'XTick',[]);
yTick = get(ax3,'YTick');
set(ax3,'YTick',yTick(2:end));

ax4 = subplot('Position', [0.15 0.13 0.8 0.2])
plot(x, dPhi_adapt.dPhi_adapt(channel, :),  'Color', [1 0.45 0])
xlim([x(1), x(end)])
ylabel('φ [rad]', 'FontSize', 14)

xlabel('Time [min]', 'FontSize', 14)
linkaxes([ax1,ax2,ax3,ax4],'x')
ax1.FontSize = 12;ax2.FontSize = 12;
ax3.FontSize = 12;ax4.FontSize = 12;

