% SAP_o243_calcorr
%
% Applies calibration coefficients and calculates
% oxygen saturation and concentration.
%
% USAGE: data = SAP_o243_calcorr(o243,ctd)
%
% INPUT
%   o243 - O2 sensor structure array with level 1 data
%   ctd - matching, time aligned ctd data table
%
% OUTPUT
%   data - level 2 data table
%
% Created by M.McFarland 2024-05-13
% Inspired by: N. Stockley
%

%% Declare function
function data = SAP_o243_calcorr(o243,ctd)

    %% Calculates oxygen saturation value
    S = ctd.Salinity;
    T = ctd.Temp;
    Ts = log((repmat(298.15,size(T,1),1) - T)./(repmat(273.15,size(T,1),1) + T));
    A0 = repmat(2.00907,size(T,1),1);
    A1 = repmat(3.22014,size(T,1),1);
    A2 = repmat(4.0501,size(T,1),1);
    A3 = repmat(4.94457,size(T,1),1);
    A4 = repmat(-0.256847,size(T,1),1);
    A5 = repmat(3.88767,size(T,1),1);
    B0 = repmat(-0.00624523,size(T,1),1);
    B1 = repmat(-0.00737614,size(T,1),1);
    B2 = repmat(-0.010341,size(T,1),1);
    B3 = repmat(-0.00817083,size(T,1),1);
    C0 = repmat(-0.000000488682,size(T,1),1);
    oxysol = exp(A0 + A1.*Ts + A2.*Ts.^2 + A3.*Ts.^3 + A4.*Ts.^4 + A5.*Ts.^5 +...
        S.*(B0 + B1.*Ts + B2.*Ts.^2 + B3.*Ts.^3) + C0.*S.^2);
    
    %% Loads data and calibration coefficients
    P = ctd.Depth; 
    K = T - 273.15;
    V = o243.data1.Voltage;
    soc = repmat(o243.info.cal.soc,size(V,1),1);
    v_offset = repmat(o243.info.cal.v_offset,size(V,1),1);
    tau20 = repmat(o243.info.cal.tau20,size(V,1),1);
    A = repmat(o243.info.cal.A,size(V,1),1);
    B = repmat(o243.info.cal.B,size(V,1),1);
    C = repmat(o243.info.cal.C,size(V,1),1);
    E = repmat(o243.info.cal.E,size(V,1),1);
    D1 = repmat(o243.info.cal.D1,size(V,1),1);
    D2 = repmat(o243.info.cal.D2,size(V,1),1);
    H1 = repmat(o243.info.cal.H1,size(V,1),1);
    H2 = repmat(o243.info.cal.H2,size(V,1),1);
    H3 = repmat(o243.info.cal.H3,size(V,1),1);
    tau_corr = 0;
    
    %% Calculates dissolved oxygen
    oxy = (soc .*(V + v_offset + tau_corr)) .* oxysol .*...
        (1 + A.*T + B.*T.^2 + C.*T.^3) .* exp(E.*P./K);

    data = table(oxysol(:,1), oxysol(:,1)*1.42903, oxy(:,1), oxy(:,1).*1.42903, oxy./oxysol*100,...
        'VariableNames',{'O2Sat_mL_L','O2Sat_mg_L','O2Conc_mL_L','O2Conc_mg_L','O2Sat_pcnt'});
    data.Properties.VariableUnits = {'mL/L','mg/L','mL/L','mg/L','%'};
        




