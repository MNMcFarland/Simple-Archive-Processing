%SAP_read_log
% 
% Read log table from target file
%
% USAGE: logTable = SAP_read_log(name,arcNames)
%
% INPUT
%   name      - (char) path and name of log file
%   arcNames  - (cell) archive numbers from arc.num structure output by
%               SAP_lvl_x functions
%
% OUTPUT
%   log - (table) sample log with rows organized by archive numbers in
%         arcNames input
%
% Malcolm McFarland 2025-05-27 edited
% ZPW 2024-06-27

function [log] = SAP_read_log(name,arcNames)

% opts = spreadsheetImportOptions('NumVariables',23);
% opts.VariableNames = {'Project','Site','Station','Archive','Date','Time','GMT_time',...
%     'GMT_offset','Latitude','Longitude','sample_salinity','sample_temp','ctd_temp',...
%     'ctd_salinity','a532','c532','c670','wind_kn','sea_state','cloud_cover',...
%     'bottom_depth_m','secchi_depth_m','notes'}; % expected variable names
% opts.VariableTypes = {'char','char','char','char','datetime','char','datetime',...
%     'double','double','double','double','double','double','double','double',...
%     'double','double','char','char','double','double','char','char'};
% opts.VariableNamesRange = '1:1';
% opts.DataRange = 'A2';
% opts.SelectedVariableNames = {'Project','Site','Archive','Date','Time','Latitude','Longitude',...
%     'wind_kn','sea_state','cloud_cover','bottom_depth_m','secchi_depth_m','notes'};

opts = detectImportOptions(name,'ExpectedNumVariables',23,'VariableNamesRange',1,...
    'DataRange','A2');
opts.VariableTypes(contains(opts.VariableNames,{'secchi','wind','archive','time'},...
    'IgnoreCase',true)) = {'char'};
opts.VariableTypes(contains(opts.VariableNames,{'date'},'IgnoreCase',true)) = {'datetime'};

log = readtable(name,opts);

% confirm data is in order corresponding to arc.num
[c,ia,ib] = intersect(arcNames,log.Archive);
log = log(ib,:);

end