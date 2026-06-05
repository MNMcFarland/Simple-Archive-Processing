%% Simple Archive Processing level 1
%
% Reads in raw data and sensor information, 
% applies time and depth offsets, and synchronizes
% data arrays according to DH4 timestamps.
% Requires sensor specific import functions (SAP_*.m)
% and calibration files (*_cal.mat)
%
% USAGE: arc = SAP_lvl_1(cfg,num)
%
% INPUT:
%   cfg - package and instrument configuration table from SAP_read_cfg.m
%   num - (char, optional) archive number(s) to process as a string for
%       a single archive or as a cell of strings for multiple archives
%
% OUTPUT:
%   arc - structure array
%
% M. McFarland 2024-05-13
% Inspired by: N. Stockley

function arc = SAP_lvl_1(cfg,num)

% parse input
if exist('num','var') && ~isempty(num) && ischar(num)
    arcnums = {num};
elseif exist('num','var') && ~isempty(num) && iscell(num)
    arcnums = num;
else
    arcnums = unique(cfg.arcnum); % all archive numbers in cfg
end

%% read data for each sensor into arc array
arc = struct('num',[],'sns',[]);%,'log',[]); % TODO: integrate station log information (date, time, lat, lon) 
for m = 1:length(arcnums) % loop through each extracted archive file
    disp(['Level 1 processing ' arcnums{m} ' (' num2str(m) ' of ' num2str(length(arcnums)) ')'])
    arc(m).num = arcnums{m};
    for n = find(strcmp(cfg.arcnum,arcnums{m}))' % loop through each sensor in each archive
        cfg_row = table2struct(cfg(n,:)); % convert cfg table row to struct for input to instrument specific function 
        
        % fh = str2func(['SAP_' cfg.sensor{n}]); % function handle for this sensor
        
        if contains(cfg.sensor{n},'acs') % This is a temporary fix to run generalized acs code, ZPW 2024-07-19
            sensorName = 'acs';
        else
            sensorName = cfg.sensor{n};
        end

        
        fh = str2func(['SAP_' sensorName]);
        arc(m).sns.(cfg.sensor{n}) = fh(cfg_row);
    end
end

%% apply time offset
for m = 1:length(arcnums) % loop through archives
    names = fieldnames(arc(m).sns);
    for n = 1:length(names) % loop through sensors
        ofst = arc(m).sns.(names{n}).info.timeoffset*1000; % convert to milliseconds
        if isfinite(ofst) && ofst~=0
            T = arc(m).sns.(names{n}).raw(:,1);
            To = T - ofst;
            shft = T(1) + sum(diff(T(To<0))); % offset as a multiple of timestamp frequency (reduces NaNs)
            Ts = T-shft;
            arc(m).sns.(names{n}).raw(:,1) = Ts;
            arc(m).sns.(names{n}).raw(Ts<0,:) = []; % remove negative times
        end
    end
end

%% time synchronize data for all instruments in each archive
for m = 1:length(arcnums) % loop through archives
    sensorNames = fieldnames(arc(m).sns);
    TT = timetable('RowTimes',milliseconds(arc(m).sns.(sensorNames{1}).raw(:,1))); % create empty timetable variable to sync all sensor timetables to
    idx = struct('start',0,'end',0); % initialize array to contain start and end column indices for each sensor
    for xx = 1:numel(sensorNames) % loop through sensors
        idx(xx).start = size(TT,2)+1; % column start indices for each sensor in TT 
        rtm = milliseconds(arc(m).sns.(sensorNames{xx}).raw(:,1)); % row times as milliseconds duration
        tt = array2timetable(arc(m).sns.(sensorNames{xx}).raw(:,2:end),'RowTimes',rtm); % convert to timetable
        TT = synchronize(TT,tt); % synchronize will default to the 'mean' method when samples share the same TimeStamp. Samples share the same timestamp when instrument is sending data packets faster than DH4 sample rate (DH4 sample rate usually 170 ms, ~ 6 Hz)
        TT = fillmissing(TT,'nearest');
        idx(xx).end = size(TT,2); % column end indices for each sensor in TT
    end
    % add synchronized data to arc
    for n = 1:numel(sensorNames)
        arc(m).sns.(sensorNames{n}).data1 = TT(:,idx(n).start:idx(n).end);
        vnm = matlab.lang.makeValidName(arc(m).sns.(sensorNames{n}).info.header(2:end,1));
        arc(m).sns.(sensorNames{n}).data1.Properties.VariableNames = vnm;
    end
end

%% depth offset
for m = 1:length(arcnums) % loop through archives
    names = fieldnames(arc(m).sns);
    n = find(contains(names,'ctd'),1); % find ctd among sensors
    if ~isempty(n)
        for p = 1:length(names) % loop through sensors
            ofst = arc(m).sns.(names{p}).info.depthoffset/100; % convert offset to meters
            arc(m).sns.(names{p}).depth = arc(m).sns.(names{n}).data1.Depth - ofst; % add to sensor data as separate field
        end
    end
end

