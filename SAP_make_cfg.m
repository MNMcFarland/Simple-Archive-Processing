% SAP_make_cfg
%
% Make configuration table template from extracted archive files
% located in target folder (pth input argument). Table will include 
% archive numbers, port numbers, path and file names.
% Other variables must be filled in manually.
%
% USAGE: 
%   fullpth = SAP_make_cfg; % open dialog to get target folder location and use default file name ('SAP_cfg.xlsx')
%   fullpth = SAP_make_cfg(name); % specify name of output file to write (e.g. 'ProjectName_cfg.xlsx')
%   fullpth = SAP_make_cfg(name,pth); % specify output file name and path of target folder
%
% INPUT
%   name - (char, optional) file name with extension (e.g. 'ProjectName_cfg.xlsx')
%       default configuration file name = 'SAP_cfg.xlsx'
%   pth - (char, optional) path to file, not including file name
%
% OUTPUT
%   partially completed configuration table written to file in target folder
%   fullpth - full path to configuration file
%
% M. McFarland 2024-05-20

function fullpth = SAP_make_cfg(name,pth)

if nargin<2
    pth = uigetdir;
end
d = dir([pth filesep '**' filesep 'archive*.*']);

cfg_array = table('Size',[length(d),11],...
    'VariableNames',{'arcnum','portnum','path','fname',...
        'sensor','mode','dev','calrow','timeoffset','depthoffset','analognum'},...
    'VariableTypes',{'cellstr','cellstr','cellstr','cellstr',...
        'cellstr','cellstr','cellstr','double','double','double','double'});

fname = {d.name}';
cfg_array.fname = fname;
cfg_array.path = {d.folder}';
cfg_array.arcnum = regexp(fname,'\d{3}$','match','once');
% cfg_array.arcnum = regexp(fname,'\d{1,3}$','match','once');
cfg_array.portnum = regexp(fname,'\d{2}','match','once');
% pnum = regexp(fname,'_(\d{2})_','tokens','once');
% cfg_array.portnum = cellfun(@(x) x{:},pnum,'uniformoutput',false);

if exist('name','var') && ischar(name)
    file = name;
else
    file = 'SAP_cfg.xlsx';
end

fullpth = [pth filesep file];
writetable(cfg_array,fullpth) % commented out by ZPW 2024-07-18 - Why? NO! BAD MM 2026-06-07
% writetable(cfg_array,file) % no, cfg file should be with the data
