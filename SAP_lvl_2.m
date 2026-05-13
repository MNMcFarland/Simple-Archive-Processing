% Simple Archive Processing level 2
%
% Applies calibrations and corrections for each
% sensor in each archive using instrument 
% type specific functions (SAP_*_calcorr.m) 
%
% USAGE: arc = SAP_lvl_2(arc)
%
% INPUT
%   arc - data structure array
%
% OUTPUT
%   arc - data structure array
%
% M. McFarland 2024-05-13
% Inspired by: N. Stockley

function arc = SAP_lvl_2(arc)

for m = 1:numel(arc) % loop through archives
    sensors = fieldnames(arc(m).sns);
    idx = find(strncmp(sensors,'ctd',3),1); % find ctd
    ctd = arc(m).sns.(sensors{idx}).data1; % get ctd data
    for n = 1:length(sensors) % loop through sensors
        switch arc(m).sns.(sensors{n}).info.type
            
            case 'acs'
                arc(m).sns.(sensors{n}).data2 = SAP_acs_calcorr(arc(m).sns.(sensors{n}),ctd);

            case {'ecobb3','ecofl3','imosc6','ecobb2'}

                % OG
                sf = arc(m).sns.(sensors{n}).info.cal.scaling_factor;
                do = arc(m).sns.(sensors{n}).info.cal.dark_offset;
                arc(m).sns.(sensors{n}).data2 = sf.*(arc(m).sns.(sensors{n}).data1 - do);

            case 'ph27'
                arc(m).sns.(sensors{n}).data2 = SAP_ph27_calcorr(arc(m).sns.(sensors{n}),ctd);

            case 'o243'
                arc(m).sns.(sensors{n}).data2 = SAP_o243_calcorr(arc(m).sns.(sensors{n}),ctd);

            % case 'lisst200x'
                % SAP_lisst_calcorr

            otherwise
                disp([sensors{n} ' in archive ' arc(m).num ' skipped'])
        end
    end
end

