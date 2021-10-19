%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WM_GM_CoV.m code takes in voxel values either from WM or GM and computes
% mean, std, CoV, exports the data for plotting and computes One-tailed
% t-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prerequisite: niftis with only WM or GM regions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adjustable parameters

maps_path = '/data/pt_02133/';

participants = {'s001', 's004', 's005', 's006', 's007', 's008', 's009', 's010', 's011', 's012'};

maps_folder1 = {'sub-s001/FMRIB/s001_7T_20191128_MR1/anat/MPMs_nav/', ...
    'sub-s004/FMRIB/s004_7T_20191216_MR1/anat/MPMs_nav/', 'sub-s005/FMRIB/s005_7T_20191216_MR1/anat/MPMs_nav/', ...
    'sub-s006/FMRIB/s006_7T_20191218_MR1/anat/MPMs_nav/', 'sub-s007/FMRIB/s007_7T_20200120_MR1/anat/MPMs_nav/', ...
    'sub-s008/FMRIB/s008_7T_20200122_MR1/anat/MPMs_nav/', 'sub-s009/FMRIB/s009_7T_20200310_MR1/anat/MPMs_nav/', ...
    'sub-s010/FMRIB/s010_7T_20200210_MR1/anat/MPMs_nav/', 'sub-s011/FMRIB/s011_7T_20200203_MR1/anat/MPMs_nav/', ...
    'sub-s012/FMRIB/s012_7T_20200225_MR1/anat/MPMs_nav/'};

maps_folder2 = {'sub-s001/FMRIB/s001_7T_20191128_MR2/anat/MPMs_nav/', ...
    'sub-s004/FMRIB/s004_7T_20191216_MR2/anat/MPMs_nav/', 'sub-s005/FMRIB/s005_7T_20191216_MR2/anat/MPMs_nav/', ...
    'sub-s006/FMRIB/s006_7T_20191218_MR2/anat/MPMs_nav/', 'sub-s007/FMRIB/s007_7T_20200120_MR2/anat/MPMs_nav/', ...
    'sub-s008/FMRIB/s008_7T_20200122_MR2/anat/MPMs_nav/', 'sub-s009/FMRIB/s009_7T_20200311_MR2/anat/MPMs_nav/', ...
    'sub-s010/FMRIB/s010_7T_20200211_MR2/anat/MPMs_nav/',  'sub-s011/FMRIB/s011_7T_20200203_MR2/anat/MPMs_nav/', ...
    'sub-s012/FMRIB/s012_7T_20200225_MR2/anat/MPMs_nav/'};

correction= {'uncorrected','f0-corrected_varadapt_virt'}; % select folder with uncorrected and corrected data

output_folder = '/data/pt_02133/2-tests/navigators/scan-rescan/';

mask_type= 'GM';% input either 'GM' or 'WM'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop through the participants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for index = 1:10 % 10 - number of participants
    mapspath1_uncor = fullfile(maps_path, maps_folder1{index}, correction{1},'Results/');
    mapspath2_uncor = fullfile(maps_path, maps_folder2{index}, correction{1},'Results/');
    mapspath1_f0cor = fullfile(maps_path, maps_folder1{index}, correction{2},'Results/');
    mapspath2_f0cor = fullfile(maps_path, maps_folder2{index}, correction{2},'Results/');

    mask_path= fullfile(maps_path, maps_folder1{index}, correction{1},'MPMCalc/');
    
    cd(mapspath1_uncor)
    uncor_MR1_nii = dir('20*/*_gnl_cp.nii');
    kk=1;
    while kk<(length(uncor_MR1_nii)+1)
           uncor_MR1{kk,1} = fullfile(uncor_MR1_nii(kk).folder, uncor_MR1_nii(kk).name);
           kk=kk+1;
    end
    
    cd(mapspath1_f0cor)
    
    f0cor_MR1_nii = dir('20*/*_gnl_cp.nii.gz');
    kk=1;
    while kk<(length(f0cor_MR1_nii)+1)
           gunzip(fullfile(f0cor_MR1_nii(kk).folder, f0cor_MR1_nii(kk).name))
           f0cor_MR1{kk,1} = fullfile(f0cor_MR1_nii(kk).folder, f0cor_MR1_nii(kk).name(1:end-3));
           kk=kk+1;
    end
    
    cd(mapspath2_f0cor)
    f0cor_MR2_nii = dir('20*/spm_r20*_gnl_cp.nii');
    kk=1;
    while kk<(length(f0cor_MR2_nii)+1)
           f0cor_MR2{kk,1} = fullfile(f0cor_MR2_nii(kk).folder, f0cor_MR2_nii(kk).name);
           kk=kk+1;
    end
    
    cd(mapspath2_uncor)
    uncor_MR2_nii = dir('20*/spm_r20*_gnl_cp.nii');
    kk=1;
    while kk<(length(uncor_MR2_nii)+1)
           uncor_MR2{kk,1} = fullfile(uncor_MR2_nii(kk).folder, uncor_MR2_nii(kk).name);
           kk=kk+1;
    end

    cd(mask_path)
    if (mask_type == 'WM')
        mask_nii = dir('c220*/*_gnl_cp_replace_val_replace_val_er2.nii');
    
    elseif (mask_type == 'GM')
        mask_nii = dir('c120*/*_gnl_cp_replace_val_replace_val_er2.nii');
    end
    mask = fullfile(mask_nii.folder, mask_nii.name);
    
    dmask=niftiread(mask);
    dmask = logical(dmask);
       
    for ll = 1:3 % where 1 = PD, 2 = R1 and 3 = R2s
        WM_uncor_MR1 = zeros([434 496 352]);
        duncor_MR1 = niftiread(uncor_MR1{ll,1});        
        WM_uncor_MR1 = duncor_MR1(dmask); 
        WM_uncor_MR1 = nonzeros(WM_uncor_MR1);
        mean_un_MR1(index,ll)=mean(WM_uncor_MR1);
        std_un_MR1(index,ll)=std(WM_uncor_MR1);
        CoV_un_MR1(index,ll)=std(WM_uncor_MR1)/mean(WM_uncor_MR1);
        
        WM_f0cor_MR1 = zeros([434 496 352]);
        df0cor_MR1 = niftiread(f0cor_MR1{ll,1});
        WM_f0cor_MR1 = df0cor_MR1(dmask);   
        WM_f0cor_MR1 = nonzeros(WM_f0cor_MR1);
        mean_f0_MR1(index,ll)= mean(WM_f0cor_MR1);
        std_f0_MR1(index,ll)=std(WM_f0cor_MR1);
        CoV_f0_MR1(index,ll)=std(WM_f0cor_MR1)/mean(WM_f0cor_MR1);

        WM_uncor_MR2 = zeros([434 496 352]);
        duncor_MR2 = niftiread(uncor_MR2{ll,1});        
        WM_uncor_MR2 = duncor_MR2(dmask); 
        WM_uncor_MR2 = nonzeros(WM_uncor_MR2);
        mean_un_MR2(index,ll)=mean(WM_uncor_MR2);
        std_un_MR2(index,ll)=std(WM_uncor_MR2);
        CoV_un_MR2(index,ll)=std(WM_uncor_MR2)/mean(WM_uncor_MR2);
        % 2-point CoV for scan-rescan plot
        CoV_un_2p(index,ll)= mean((std([WM_uncor_MR1, WM_uncor_MR2], 0, 2)./mean([WM_uncor_MR1, WM_uncor_MR2], 2)));

        WM_f0cor_MR2 = zeros([434 496 352]);
        df0cor_MR2 = niftiread(f0cor_MR2{ll,1});
        WM_f0cor_MR2 = df0cor_MR2(dmask);   
        WM_f0cor_MR2 = nonzeros(WM_f0cor_MR2);
        mean_f0_MR2(index,ll)= mean(WM_f0cor_MR2);
        std_f0_MR2(index,ll)=std(WM_f0cor_MR2);
        CoV_f0_MR2(index,ll)=std(WM_f0cor_MR2)/mean(WM_f0cor_MR2);
        % 2-point CoV for scan-rescan plot
        CoV_f0_2p(index,ll)= mean((std([WM_f0cor_MR1, WM_f0cor_MR2], 0, 2)./mean([WM_f0cor_MR1, WM_f0cor_MR2], 2)));
    end   
end
% create arrays MR1 and MR2 arrays summarizing the basic info from session
% 1 and session 2 respectively

MR1 = [];
for index = 1:10
    MR1=[MR1,mean_un_MR1(index,1), std_un_MR1(index,1), CoV_un_MR1(index,1),...
    mean_f0_MR1(index,1), std_f0_MR1(index,1), CoV_f0_MR1(index,1),...
    mean_un_MR1(index,2), std_un_MR1(index,2),CoV_un_MR1(index,2), ...
    mean_f0_MR1(index,2), std_f0_MR1(index,2),CoV_f0_MR1(index,2), ...
    mean_un_MR1(index,3), std_un_MR1(index,3),CoV_un_MR1(index,3),...
    mean_f0_MR1(index,3), std_f0_MR1(index,3),CoV_f0_MR1(index,3)]
end
MR1 =reshape(MR1,[18,10]);
MR1 = MR1';

MR2 = [];
for index = 1:10
    MR2=[MR2,mean_un_MR2(index,1), std_un_MR2(index,1), CoV_un_MR2(index,1),...
    mean_f0_MR2(index,1), std_f0_MR2(index,1), CoV_f0_MR2(index,1),...
    mean_un_MR2(index,2), std_un_MR2(index,2),CoV_un_MR2(index,2), ...
    mean_f0_MR2(index,2), std_f0_MR2(index,2),CoV_f0_MR2(index,2), ...
    mean_un_MR2(index,3), std_un_MR2(index,3),CoV_un_MR2(index,3),...
    mean_f0_MR2(index,3), std_f0_MR2(index,3),CoV_f0_MR2(index,3)]
end
MR2 =reshape(MR2,[18,10]);
MR2 = MR2';

% relative change 
rel_change_CoV = ((CoV_f0_2p - CoV_un_2p)./ CoV_un_2p)*100

%exporting the data to be able to use old R code for plotting
output_path = '/data/pt_02133/2-tests/navigators/scan-rescan/CoV/';
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
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_pmcOFF_navOFF.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_un_MR1(index,contr_type));
        fclose(fileID);        
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_pmcOFF_navON.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_f0_MR1(index,contr_type));
        fclose(fileID);        
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_pmcON_navOFF.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_un_MR2(index,contr_type));
        fclose(fileID);        
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_pmcON_navON.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_f0_MR2(index,contr_type));
        fclose(fileID);        
    end
end

%exporting the data to be able to use old R code for plotting
output_path = '/data/pt_02133/2-tests/navigators/scan-rescan/CoV_2p/';
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
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_navOFF.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_un_2p(index,contr_type));
        fclose(fileID);        
        filename = strcat(participants(index), '_',mask_type, '_', contrast, '_navON.txt');
        fileID = fopen(filename{1},'w');
        fprintf(fileID, '%f', CoV_f0_2p(index,contr_type));
        fclose(fileID);        
    end
end

%% Statistical testing

% one tailed t-test testing if x has larger mean than y
[h_PD,p_PD,ci_PD,stats_PD] = ttest(CoV_un_2p(:,1), CoV_f0_2p(:,1),  'Tail','right');
[h_R1,p_R1,ci_R1,stats_R1] = ttest(CoV_un_2p(:,2), CoV_f0_2p(:,2),  'Tail','right');
[h_R1,p_R2s,ci_R2s,stats_R2s] = ttest(CoV_un_2p(:,3), CoV_f0_2p(:,3),  'Tail','right');


