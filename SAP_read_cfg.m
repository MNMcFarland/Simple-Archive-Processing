% SAP_read_cfg
%
% Read configuration table from target folder and file
%
% USAGE: cfg = SAP_read_cfg(name)
%
% INPUT
%   name - (char, optional) path and name of configuration file (e.g. 'extracted\ProjectName_cfg.xlsx')
%
% OUTPUT
%   cfg - configuration table
%
% M. McFarland 2024-05-20

function cfg = SAP_read_cfg(name)

if nargin==0
    [nm,pth] = uigetfile('*.xlsx');
    name = [pth nm];
end

opts = spreadsheetImportOptions('NumVariables',11);
% opts.VariableNames =
% {'arcnum','portnum','path','fname','sensor','mode','dev','calrow','timeoffset','depthoffset','analognum'}; % expected variable names
opts.VariableNamesRange = '1:1';
opts.DataRange = 'A2';
opts.VariableTypes = {'char','char','char','char','char','char','char','double','double','double','double'};
cfg = readtable(name,opts);
