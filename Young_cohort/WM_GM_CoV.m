%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WM_GM_CoV.m code takes in voxel values either from WM or GM and computes
% mean, std, CoV, exports the data for plotting and computes 2-way ANOVA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prerequisite: niftis with only WM or GM regions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adjustable parameters
maps_path = '/data/pt_02199/maps_filtered_navs/';

%load participant codes
participant_list = fopen('/data/pt_02199/participant_list.txt','r');
participant = textscan(participant_list, '%[^\n]');
fclose(participant_list);

pmc = {'pmcOFF', 'pmcON'};
correction= {'uncorrected_varadapt_all', 'f0-corrected_varadapt_virt'}; % select folder with uncorrected and corrected data
output_folder = '/data/pt_02199/CoV';

mask_type= 'GM';% select 'GM'or 'WM'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop through the participants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for index = 1:length(participant{1}) % number of participants
    mapspath1_uncor = fullfile(maps_path, participant{1}{index}, correction{1}, pmc{1},'Results/');
    mapspath2_uncor = fullfile(maps_path, participant{1}{index}, correction{1}, pmc{2},'Results/');
    mapspath1_f0cor = fullfile(maps_path, participant{1}{index}, correction{2}, pmc{1},'Results/');
    mapspath2_f0cor = fullfile(maps_path, participant{1}{index}, correction{2}, pmc{2},'Results/');

    mask1_path= fullfile(mapspath1_uncor,'../','MPMCalc/');
    mask2_path= fullfile(mapspath2_uncor,'../','MPMCalc/');
    
    cd(mapspath1_uncor)
    uncor_MR1_nii = dir('*/*_gnl_cp.nii');
    kk=1;
    while kk<(length(uncor_MR1_nii)+1)
           uncor_MR1{kk,1} = fullfile(uncor_MR1_nii(kk).folder, uncor_MR1_nii(kk).name);
           kk=kk+1;
    end
    
    cd(mapspath1_f0cor)
    
    f0cor_MR1_nii = dir('*/*_gnl_cp.nii');
    kk=1;
    while kk<(length(f0cor_MR1_nii)+1)
           f0cor_MR1{kk,1} = fullfile(f0cor_MR1_nii(kk).folder, f0cor_MR1_nii(kk).name);
           kk=kk+1;
    end
    
    cd(mapspath2_f0cor)
    f0cor_MR2_nii =  dir('*/*_gnl_cp.nii');
    f0cor_MR2_nii = f0cor_MR2_nii(~startsWith({f0cor_MR2_nii.name},'spm_r')); 
    kk=1;
    while kk<(length(f0cor_MR2_nii)+1)
           f0cor_MR2{kk,1} = fullfile(f0cor_MR2_nii(kk).folder, f0cor_MR2_nii(kk).name);
           kk=kk+1;
    end
    
    cd(mapspath2_uncor)
    uncor_MR2_nii = dir('*/*_gnl_cp.nii');
    uncor_MR2_nii = uncor_MR2_nii(~startsWith({uncor_MR2_nii.name},'spm_r')); 
    kk=1;
    while kk<(length(uncor_MR2_nii)+1)
           uncor_MR2{kk,1} = fullfile(uncor_MR2_nii(kk).folder, uncor_MR2_nii(kk).name);
           kk=kk+1;
    end

    cd(mask1_path)
    if (mask_type == 'WM')
        mask1_nii = dir('c2*/*_gnl_cp_replace_val_replace_val_er2.nii');
    
    elseif (mask_type == 'GM')
        mask1_nii = dir('c1*/*_gnl_cp_replace_val_replace_val_er2.nii');
    end
    mask1 = fullfile(mask1_nii.folder, mask1_nii.name);
    dmask1=niftiread(mask1);
    dmask1 = logical(dmask1);
    
    cd(mask2_path)
    if (mask_type == 'WM')
        mask2_nii = dir('c2*/*_gnl_cp_replace_val_replace_val_er2.nii');
    
    elseif (mask_type == 'GM')
        mask2_nii = dir('c1*/*_gnl_cp_replace_val_replace_val_er2.nii');
    end
    mask2 = fullfile(mask2_nii.folder, mask2_nii.name);
    dmask2=niftiread(mask2);
    dmask2 = logical(dmask2);
    
    
    for ll = 1:3 % where 1 = PD, 2 = R1 and 3 = R2s
        WM_uncor_MR1 = zeros([434 496 352]);
        duncor_MR1 = niftiread(uncor_MR1{ll,1});        
        WM_uncor_MR1 = duncor_MR1(dmask1); 
        WM_uncor_MR1 = nonzeros(WM_uncor_MR1);
        mean_un_MR1(index,ll)=mean(WM_uncor_MR1);
        std_un_MR1(index,ll)=std(WM_uncor_MR1);
        CoV_un_MR1(index,ll)=std(WM_uncor_MR1)/mean(WM_uncor_MR1);
        
        WM_f0cor_MR1 = zeros([434 496 352]);
        df0cor_MR1 = niftiread(f0cor_MR1{ll,1});
        WM_f0cor_MR1 = df0cor_MR1(dmask1);   
        WM_f0cor_MR1 = nonzeros(WM_f0cor_MR1);
        mean_f0_MR1(index,ll)= mean(WM_f0cor_MR1);
        std_f0_MR1(index,ll)=std(WM_f0cor_MR1);
        CoV_f0_MR1(index,ll)=std(WM_f0cor_MR1)/mean(WM_f0cor_MR1);
    end
     
    for ll = 1:3 % where 1 = PD, 2 = R1 and 3 = R2s
        WM_uncor_MR2 = zeros([434 496 352]);
        duncor_MR2 = niftiread(uncor_MR2{ll,1});        
        WM_uncor_MR2 = duncor_MR2(dmask2); 
        WM_uncor_MR2 = nonzeros(WM_uncor_MR2);
        mean_un_MR2(index,ll)=mean(WM_uncor_MR2);
        std_un_MR2(index,ll)=std(WM_uncor_MR2);
        CoV_un_MR2(index,ll)=std(WM_uncor_MR2)/mean(WM_uncor_MR2);
        
        WM_f0cor_MR2 = zeros([434 496 352]);
        df0cor_MR2 = niftiread(f0cor_MR2{ll,1});
        WM_f0cor_MR2 = df0cor_MR2(dmask2);   
        WM_f0cor_MR2 = nonzeros(WM_f0cor_MR2);
        mean_f0_MR2(index,ll)= mean(WM_f0cor_MR2);
        std_f0_MR2(index,ll)=std(WM_f0cor_MR2);
        CoV_f0_MR2(index,ll)=std(WM_f0cor_MR2)/mean(WM_f0cor_MR2);
    end
end

% create arrays MR1 and MR2 arrays summarizing the basic info from pmcOFF
% and pmcON respectively
MR1 = [];
for index = 1:length(participant{1})
    MR1=[MR1,mean_un_MR1(index,1), std_un_MR1(index,1), CoV_un_MR1(index,1),...
    mean_f0_MR1(index,1), std_f0_MR1(index,1), CoV_f0_MR1(index,1),...
    mean_un_MR1(index,2), std_un_MR1(index,2),CoV_un_MR1(index,2), ...
    mean_f0_MR1(index,2), std_f0_MR1(index,2),CoV_f0_MR1(index,2), ...
    mean_un_MR1(index,3), std_un_MR1(index,3),CoV_un_MR1(index,3),...
    mean_f0_MR1(index,3), std_f0_MR1(index,3),CoV_f0_MR1(index,3)]
end
MR1 =reshape(MR1,[18,length(participant{1})]);
MR1 = MR1';

MR2 = [];
for index = 1:length(participant{1})
    MR2=[MR2,mean_un_MR2(index,1), std_un_MR2(index,1), CoV_un_MR2(index,1),...
    mean_f0_MR2(index,1), std_f0_MR2(index,1), CoV_f0_MR2(index,1),...
    mean_un_MR2(index,2), std_un_MR2(index,2),CoV_un_MR2(index,2), ...
    mean_f0_MR2(index,2), std_f0_MR2(index,2),CoV_f0_MR2(index,2), ...
    mean_un_MR2(index,3), std_un_MR2(index,3),CoV_un_MR2(index,3),...
    mean_f0_MR2(index,3), std_f0_MR2(index,3),CoV_f0_MR2(index,3)]
end
MR2 =reshape(MR2,[18,length(participant{1})]);
MR2 = MR2';

%exporting the data to be able to use old R code for plotting
output_path = '/data/pt_02199/results/CoV/';
cd(output_path)
for index = 1:10
    for contr_type = 1:3
        if contr_type == 1
            contrast = 'PD';
        elseif contr_type == 2
            contrast = 'R1';
        else
            contrast = 'R2s';
        end   
        filename = strcat(participant{1}{index}, '_',mask_type, '_', contrast, '_pmcOFF_navOFF.txt');
        fileID = fopen(filename,'w');
        fprintf(fileID, '%f', CoV_un_MR1(index,contr_type));
        fclose(fileID);        
        filename = strcat(participant{1}{index}, '_',mask_type, '_', contrast, '_pmcOFF_navON.txt');
        fileID = fopen(filename,'w');
        fprintf(fileID, '%f', CoV_f0_MR1(index,contr_type));
        fclose(fileID);        
        filename = strcat(participant{1}{index}, '_',mask_type, '_', contrast, '_pmcON_navOFF.txt');
        fileID = fopen(filename,'w');
        fprintf(fileID, '%f', CoV_un_MR2(index,contr_type));
        fclose(fileID);        
        filename = strcat(participant{1}{index}, '_',mask_type, '_', contrast, '_pmcON_navON.txt');
        fileID = fopen(filename,'w');
        fprintf(fileID, '%f', CoV_f0_MR2(index,contr_type));
        fclose(fileID);        
    end
end

%% stats 2-way ANOVA
% pmc OFF, pmcOFF, pmcON, pmcON - testing pmc OFF-ON
PD_means = zeros(22,2);R1_means = zeros(22,2);R2s_means = zeros(22,2);
for participant = 1:11
    PD_means(2*participant,:) = [MR1(participant,1), MR2(participant,1)];
    PD_means(2*participant-1,:) = [MR1(participant,4), MR2(participant,4)];    
    R1_means(2*participant,:) = [MR1(participant,7), MR2(participant,7)];
    R1_means(2*participant-1,:) = [MR1(participant,10), MR2(participant,10)];
    R2s_means(2*participant,:) = [MR1(participant,13), MR2(participant,13)];
    R2s_means(2*participant-1,:) = [MR1(participant,16), MR2(participant,16)];    
end
anova2(PD_means,11)
anova2(R1_means,11)
anova2(R2s_means,11)

