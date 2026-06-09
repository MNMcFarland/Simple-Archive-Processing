% ac_cal_eval_load.m

%% Set WET Labs Toolbox folder
% disp('Set path to processing toolbox folder. Type "dbcont" when finished.')
% keyboard
% toolbox_folder = pwd;
%toolbox_folder = uigetdir([],'Set path to processing toolbox folder');

%% Select directory with calibration files
% disp('Set path to calibration folder. Type "dbcont" when finished.')
% keyboard
% cal_folder = pwd;
cal_folder = uigetdir([],'Set path to calibration folder');
%all_cals = dir('wc*.dat');
all_cals = dir([cal_folder filesep 'wc*.dat']);
for x = 1:size(all_cals,1)
    cal_files(x,1:5) = regexp(all_cals(x).name,'_','split');
end
ac_list = unique(cal_files(:,2));

%% Select ac device
if length(ac_list) == 1
    working_ac = ac_list{1};
elseif length(ac_list) > 1
    disp(string(ac_list))
    working_ac = input('Select AC device: ','s');
    while ~any(strcmp(working_ac,ac_list))
        disp('Selected AC device not found.')
        working_ac = input('Select AC device: ','s');
    end
end
select_dev_str = horzcat('Selected device: ',working_ac);
disp(select_dev_str)

% Process for selected AC device
%% Load existing device cal.mat file & ts_corr.mat file & match to device wavelengths
% cd(toolbox_folder);
ac_cal_mat = strcat(working_ac,'_cal.mat');
cpth = fileparts(which(ac_cal_mat));

load(ac_cal_mat)
eval(['working_cal = ' strcat(working_ac,'_cal') ';']);
eval(['working_corr = ' strcat(working_ac,'_corr') ';']);
if strncmp(working_ac,'ac9',3)
    load('ac9_ts_corr.mat')
    ts_corr = zeros(length(wl_a),4);
    for x = 1:length(wl_a)
        match_a = find(wl_a(x) == ac9_ts_wavelength(:)); %#ok<*IDISVAR>
        match_c = find(wl_c(x) == ac9_ts_wavelength(:));
        ts_corr(x,1) = ac9_ts_salt_a(match_a); % corr_salt_a
        ts_corr(x,2) = ac9_ts_salt_c(match_c); % corr_salt_c
        ts_corr(x,3) = ac9_ts_temp_ac(match_a); % corr_temp_a
        ts_corr(x,4) = ac9_ts_temp_ac(match_c); % corr_temp_c
    end
    clear('y','ac9_ts_salt_a','ac9_ts_salt_c','ac9_ts_source',...
        'ac9_ts_temp_ac','ac9_ts_wavelength','match_a','match_c')
elseif strncmp(working_ac,'acs',3)
    load('acs_ts_corr.mat')
    ts_corr = zeros(length(wl_a),4);
    for x = 1:length(wl_a)
        match_a = find(wl_a(x) == acs_ts_wavelength(:)); %#ok<*IDISVAR>
        match_c = find(wl_c(x) == acs_ts_wavelength(:));
        ts_corr(x,1) = acs_ts_salt_a(match_a); % corr_salt_a
        ts_corr(x,2) = acs_ts_salt_c(match_c); % corr_salt_c
        ts_corr(x,3) = acs_ts_temp_ac(match_a); % corr_temp_a
        ts_corr(x,4) = acs_ts_temp_ac(match_c); % corr_temp_c
    end
    clear('x','acs_ts_salt_a','acs_ts_salt_c','acs_ts_source',...
        'acs_ts_temp_ac','acs_ts_wavelength','match_a','match_c')
end

%% Select cal dates for selected AC device
where_working_ac = find(strcmp(working_ac,cal_files(:,2)));
date_list = unique(cal_files(where_working_ac,3));
if length(date_list) == 1
    working_date = date_list{1};
elseif length(date_list) > 1
    working_date_str = input('Select cal date (yyyy-mm-dd): ','s');
    working_date = datestr(datenum(working_date_str),'yyyymmdd');
    while ~any(strcmp(working_date,date_list))
        disp('Selected date not found.')
        working_date_str = input('Select cal date (yyyy-mm-dd): ','s');
        working_date = datestr(datenum(working_date_str),'yyyymmdd');
    end
end
select_date_str = horzcat('Selected cal date: ',datestr(datenum(working_date,'yyyymmdd'),'yyyy-mm-dd'));
disp(select_date_str)

%% Process cals for selected date
% Load selected cal data
cd(cal_folder);
all_selected_rows = find(strcmp(working_ac,cal_files(:,2))&strcmp(working_date,cal_files(:,3)));
for x = 1:length(all_selected_rows)
    x1 = all_selected_rows(x);
    data = importdata(all_cals(x1).name);
    data_a(x1,1:length(col_a)) = mean(data.data(:,col_a));
    data_c(x1,1:length(col_c)) = mean(data.data(:,col_c));
    cal_temp(x1,1) = str2double(cal_files{x1,5}(1:end-4))./10; % assumes 1 decimal place
    cal_rep{x1,1} = cal_files{x1,4};
end
% Apply temperature correction & calculate differences
corr_a = data_a - (cal_temp-12).*ts_corr(:,3)';
corr_c = data_c - (cal_temp-12).*ts_corr(:,4)';
diff_row = 1;
for x = 1:length(all_selected_rows)-1
    for y = x+1:length(all_selected_rows)
        cal_diffs_a(diff_row,:) = corr_a(x,:) - corr_a(y,:);
        cal_diffs_c(diff_row,:) = corr_c(x,:) - corr_c(y,:);
        cal_diffs{diff_row,1} = strcat(cal_rep{x},'-',cal_rep{y});
        diff_row = diff_row+1;
    end
end
% Plot corrected calibrations & differences
clist_cal = colormap(jet(length(all_selected_rows)));
clist_diff = colormap(jet(length(cal_diffs)));
close(gcf)
figure('Name','Absorption','NumberTitle','off')
subplot(2,1,1)
hold on
for x = 1:length(all_selected_rows)
    plot(wl_a,corr_a(x,:),'Color',clist_cal(x,:))
end
plot(wl_a,working_corr{end,3},'Color',[0 0 0],'LineStyle','--')
plot(wl_a,working_corr{end-1,3},'Color',[0 0 0],'LineStyle','-.')
plot(wl_a,working_corr{end-2,3},'Color',[0 0 0],'LineStyle','-.')
xlim([wl_a(1) wl_a(end)])
legend(cal_rep,'Location','southoutside','Orientation','horizontal')
subplot(2,1,2)
hold on
for x = 1:length(cal_diffs)
    plot(wl_a,cal_diffs_a(x,:),'Color',clist_diff(x,:))
end
xlim([wl_a(1) wl_a(end)])
ylim([-0.01 0.01])
if strncmp(working_ac,'ac9',3)
    plot(wl_a,repmat(-0.002,1,length(wl_a)),'k--')
    plot(wl_a,repmat(0.002,1,length(wl_a)),'k--')
elseif strncmp(working_ac,'acs',3)
    plot(wl_a,repmat(-0.005,1,length(wl_a)),'k--')
    plot(wl_a,repmat(0.005,1,length(wl_a)),'k--')
end
legend(cal_diffs,'Location','southoutside','Orientation','horizontal')
figure('Name','Attenuation','NumberTitle','off')
subplot(2,1,1)
hold on
for x = 1:length(all_selected_rows)
    plot(wl_c,corr_c(x,:),'Color',clist_cal(x,:))
end
plot(wl_c,working_corr{end,4},'Color',[0 0 0],'LineStyle','--')
plot(wl_c,working_corr{end-1,4},'Color',[0 0 0],'LineStyle','-.')
plot(wl_c,working_corr{end-2,4},'Color',[0 0 0],'LineStyle',':')
xlim([wl_c(1) wl_c(end)])
legend(cal_rep,'Location','southoutside','Orientation','horizontal')
subplot(2,1,2)
hold on
for x = 1:length(cal_diffs)
    plot(wl_c,cal_diffs_c(x,:),'Color',clist_diff(x,:))
end
xlim([wl_c(1) wl_c(end)])
ylim([-0.01 0.01])
if strncmp(working_ac,'ac9',3)
    plot(wl_c,repmat(-0.002,1,length(wl_a)),'k--')
    plot(wl_c,repmat(0.002,1,length(wl_a)),'k--')
elseif strncmp(working_ac,'acs',3)
    plot(wl_c,repmat(-0.005,1,length(wl_a)),'k--')
    plot(wl_c,repmat(0.005,1,length(wl_a)),'k--')
end
legend(cal_diffs,'Location','southoutside','Orientation','horizontal')
% Add automatic quality check here!!!

%% Load selected cals
working_cal_length = size(working_cal,1);
working_corr_length = size(working_corr,1);
last_corr_date_vec = working_corr{working_corr_length,1};
last_corr_date_str = datestr([last_corr_date_vec 0 0 0],'yyyymmdd');
if ~strcmp(last_corr_date_str,working_date)
    pair_a = input('Select best absoprtion cal pair (e.g. b,d): ','s');
    pair_c = input('Select best attentuation cal pair (e.g. b,d): ','s');
    split_a = regexp(pair_a,',','split');
    split_c = regexp(pair_c,',','split');
    where_a(1,1) = find(strcmp(working_ac,cal_files(:,2))&strcmp(working_date,cal_files(:,3))&strcmp(split_a{1,1},cal_files(:,4)));
    where_a(2,1) = find(strcmp(working_ac,cal_files(:,2))&strcmp(working_date,cal_files(:,3))&strcmp(split_a{1,2},cal_files(:,4)));
    where_c(1,1) = find(strcmp(working_ac,cal_files(:,2))&strcmp(working_date,cal_files(:,3))&strcmp(split_c{1,1},cal_files(:,4)));
    where_c(2,1) = find(strcmp(working_ac,cal_files(:,2))&strcmp(working_date,cal_files(:,3))&strcmp(split_c{1,2},cal_files(:,4)));
    raw_cals = unique([where_a;where_c]);
    use_last_dev = input('Use last device file? (Y/N): ','s');
    switch use_last_dev
        case {'Y','y','YES','Yes','yes'}
            dev_file = working_cal{working_cal_length,2};
        case {'N','n','NO','No','no'}
            dev_file = input('What device file was used?: ','s');
    end
    project = input('What project was this cal for?: ','s');
    which_orientation = input('What orientation was used?: ','s');
    switch which_orientation
        case {'V','v','VERT','Vert','vert','VERTICAL','Vertical','vertical'}
            orientation = 'vertical';
        case {'H','h','HORZ','Horz','horz','HORIZONTAL','Horizontal','horizontal'}
            orientation = 'horizontal';
    end
    for x = 1:length(raw_cals)
        x1 = raw_cals(x);
        working_cal{working_cal_length+x,1} = all_cals(x1).name;
        working_cal{working_cal_length+x,2} = dev_file;
        working_date_vec = datevec(working_date,'yyyymmdd');
        working_cal{working_cal_length+x,3} = working_date_vec(1:3);
        working_cal{working_cal_length+x,4} = project;
        working_cal{working_cal_length+x,5} = orientation;
        working_cal{working_cal_length+x,6} = str2double(cal_files{x1,5}(1:end-4))./10; % assumes 1 decimal place
        data = importdata(all_cals(x1).name);
        working_cal{working_cal_length+x,7} = mean(data.data(:,col_a));
        working_cal{working_cal_length+x,8} = mean(data.data(:,col_c));
    end
    for x = 1:length(where_a)
        x1 = where_a(x);
        data = importdata(all_cals(x1).name);
        final_cal_a(x,1:length(col_a)) = mean(data.data(:,col_a));
        final_a_cal_temp(x,1) = str2double(cal_files{x1,5}(1:end-4))./10; % assumes 1 decimal place
    end
    for x = 1:length(where_c)
        x1 = where_c(x);
        data = importdata(all_cals(x1).name);
        final_cal_c(x,1:length(col_c)) = mean(data.data(:,col_c));
        final_c_cal_temp(x,1) = str2double(cal_files{x1,5}(1:end-4))./10; % assumes 1 decimal place
    end
    final_corr_a = mean(final_cal_a - (final_a_cal_temp-12).*ts_corr(:,3)',1);
    final_corr_c = mean(final_cal_c - (final_c_cal_temp-12).*ts_corr(:,4)',1);
    working_corr{working_corr_length+1,1} = working_date_vec(1:3);
    working_corr{working_corr_length+1,2} = project;
    working_corr{working_corr_length+1,3} = final_corr_a;
    working_corr{working_corr_length+1,4} = final_corr_c;
    disp('Review calibration data in working_cal & working_corr before saving.')
elseif strcmp(last_corr_date_str,working_date)
    disp('Calibration for selected date already included!')
end
% cd(toolbox_folder);
%% Save calibration file
ready4save = input('Ready to save cal? (Y/N): ','s');
switch ready4save
    case {'Y','y','YES','Yes','yes'}
        %cd(toolbox_folder);
        eval(['' strcat(working_ac,'_cal') ' = working_cal;']);
        eval(['' strcat(working_ac,'_corr') ' = working_corr;']);
        % save(ac_cal_mat,'wl_a','wl_c','col_a','col_c',strcat(working_ac,'_cal'),strcat(working_ac,'_corr'));
        save([cpth filesep ac_cal_mat],'wl_a','wl_c','col_a','col_c',strcat(working_ac,'_cal'),strcat(working_ac,'_corr'));
    case {'N','n','NO','No','no'}
        % do nothing!
end

%% Evaluate full calibration history
near_488_a = nearestpoint(488,wl_a);
near_532_a = nearestpoint(532,wl_a);
near_650_a = nearestpoint(650,wl_a);
near_488_c = nearestpoint(488,wl_c);
near_532_c = nearestpoint(532,wl_c);
near_650_c = nearestpoint(650,wl_c);
clist_cal_hist = colormap(jet(size(working_corr,1)));
close(gcf);
figure('Name','Absorption Cal History','NumberTitle','off')
subplot(2,3,1:3)
hold on
for x = 2:size(working_corr,1)
    plot(wl_a,working_corr{x,3},'Color',clist_cal_hist(x,:))
end
xlim([wl_a(1) wl_a(end)])
subplot(2,3,4)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,3}(near_488_a),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('488 nm')
subplot(2,3,5)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,3}(near_532_a),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('532 nm')
subplot(2,3,6)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,3}(near_650_a),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('650 nm')

figure('Name','Attenuation Cal History','NumberTitle','off')
subplot(2,3,1:3)
hold on
for x = 2:size(working_corr,1)
    plot(wl_c,working_corr{x,4},'Color',clist_cal_hist(x,:))
end
xlim([wl_c(1) wl_c(end)])
subplot(2,3,4)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,4}(near_488_c),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('488 nm')
subplot(2,3,5)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,4}(near_532_c),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('532 nm')
subplot(2,3,6)
hold on
for x = 2:size(working_corr,1)
    plot(datenum(working_corr{x,1}),working_corr{x,4}(near_650_c),'*','MarkerEdgeColor',clist_cal_hist(x,:));
end
datetick('x','yy-mmm')
title('650 nm')
