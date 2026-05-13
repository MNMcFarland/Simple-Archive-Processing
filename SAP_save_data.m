function [] = SAP_save_data(logVar,arcVar,savePath)

%SAP_save_data
% 
% Splits arc and log variables by individual station and saves as separate
% *.mat files named "project_date_station_op"
%
% USEAGE:  SAP_save_data(logVar,arcVar,savePath)
%  
% INPUT:
%   logVar   - (table) sample log from SAP_read_log function
%   arcVar   - (struct) structured array output from SAP_lvl_X functions
%   savePath - (char) path to save directory. If not provided, defaults to
%              current working directory
%
% OUTPUT:
%   saves all individual stations as separate *.mat files in savePath directory
%
% ZPW 2024-06-28

if nargin < 3
    savePath = pwd;
end

for xx = 1:size(logVar,1)
    arc = arcVar(xx).sns;
    log = logVar(xx,:);
    log.Date.Format = 'yyyyMMdd';
    sampleName = [log.Project{:},'_',char(log.Date),'_',log.Site{:}];
    save([savePath,filesep,sampleName,'_op.mat'],'arc','log');
end

end

