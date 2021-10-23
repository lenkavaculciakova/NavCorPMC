% First extract all the navigators and save them in a structure using the
% recon code containing 'save' function

addpath('/data/pt_02199/scripts');

datapath = '/data/pt_02199/images_filtered_navs/';

%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);

correction= {'f0-corrected_varadapt_virt'};
TR = 27.5; %ms


for subject = 1:length(participant{1})
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
        dPhi = load('dPhi.mat');
        dPhi_cpx = load('dPhi_cpx.mat');
        dPhi_adapt = load('dPhi_adapt.mat');
        SNRperTimePoint = load('SNRperTimePoint.mat');
        
        x = 1:length(dPhi.dPhi(1,:));
        fig = figure('visible','off')
        for channel = 1:32
            subplot(8,4,channel)
            yyaxis left
            plot(x, SNRperTimePoint.SNRperTimePoint(channel,:), 'Color', [0,0,0]+0.8) ;
            hold on
%             yyaxis left
%             plot(x, dPhi_cpx.dPhi_cpx(channel,:), 'r') 
%             hold on
%             yyaxis left
%             plot(x, dPhi_adapt.dPhi_adapt(channel,:),'g') 
%             hold on
            yyaxis right
            
            above_dPhi = (SNRperTimePoint.SNRperTimePoint(channel,:) > 40);
            
            bottom_dPhi = dPhi.dPhi(channel,:);
            top_dPhi = dPhi.dPhi(channel,:);
            bottom_dPhi(~above_dPhi) = NaN;
            top_dPhi(above_dPhi) = NaN;
            
            plot(x, bottom_dPhi, 'k', x, top_dPhi, 'r') ;
            
            ax = gca;
            ax.YAxis(1).Color = [0,0,0]+0.8;
            ax.YAxis(2).Color = 'k';        
            hold off
        end
        subplot(8,4,16)
        ylabel('dPhi [Hz]', 'FontSize', 12)
        subplot(8,4,13)
        yyaxis left
        ylabel('SNR per time point', 'FontSize', 12)
        set(gca, 'SortMethod', 'depth')
        sgtitle(strcat('Subject ', num2str(subject), ', measurement ', num2str(raw)), 'FontSize', 14);

        savefig(fullfile(path{1},'../',  strcat('Subject', num2str(subject), '-measurement', num2str(raw),'_rawnav.fig')));

        h=gcf;
        set(h,'PaperOrientation','portrait');
        set(h,'PaperUnits','normalized');
        set(h,'PaperPosition', [0 0 1 1]);
        print(gcf, '-dpdf', fullfile(path{1},'../', strcat('Subject', num2str(subject), '-measurement', num2str(raw),'_rawnav.pdf')));
        
        close(fig)
    end
end
