% SAP_ph27_calcorr
%
% Applies the calibration coefficients and calculates pH
% and oxidation-reduction potential (ORP).
%
% USAGE: data = SAP_ph27_calcorr(ph27,ctd)
%
% INPUT
%   ph27 - pH sensor structure array with level 1 data
%   ctd - matching, time aligned ctd data table
%
% OUTPUT
%   data - level 2 data table
%
% M. McFarland 2024-05-13
% Inspired by: N. Stockley
%

%% Declare function
function data = SAP_ph27_calcorr(ph27,ctd)

    voltage_out = ph27.data1.Voltage;
    T = ctd.Temp + 273.15;
    ph_slope = repmat(ph27.info.cal.ph_slope,size(voltage_out,1),1);
    ph_offset = repmat(ph27.info.cal.ph_offset,size(voltage_out,1),1);
    orp_m = repmat(ph27.info.cal.orp_m,size(voltage_out,1),1);
    orp_b = repmat(ph27.info.cal.orp_b,size(voltage_out,1),1);
    seven = repmat(7,size(voltage_out,1),1);
    
    %% Calculate pH & ORP
    ph = seven + (voltage_out - ph_offset)./(1.98416e-4 .* T .* ph_slope);
    orp = orp_m .* (voltage_out - orp_b) .* 1000;
    
    %% Assigns calculated pH * ORP
    % ph_array.data.corr.native.header = {'Time','ms';'Depth','m';'pH','';'ORP','mV'};
    % ph_array.data.corr.native.ph = [ph_data(:,1:2) ph(:,1) orp(:,1)];
    
    data = table(ph,orp,'VariableNames',{'pH','ORP'});
    data.Properties.VariableUnits = {'','mV'};

