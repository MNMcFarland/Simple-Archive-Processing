% SAP_eco_calcorr - Not used
%
% Applies the calibration scaling factor and dark offset
% to the raw data. 
%
% USAGE: 

function data = SAP_eco_calcorr(eco)

sf = eco.info.cal.scaling_factor;
do = eco.info.cal.dark_offset;

data = sf.*(eco.data1 - do);

