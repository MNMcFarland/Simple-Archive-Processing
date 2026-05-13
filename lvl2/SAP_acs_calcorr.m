% SAP_acs_calcorr
%
% SAP_acs_calcorr applies the pure water calibration and temperature and
% salinity corrections to the raw ac data.
%
% USAGE: data = SAP_acs_calcorr(acs,ctd)
%
% INPUT
%   acs - acs sensor structure array with level 1 data
%   ctd - matching, time aligned ctd data table
%
% OUTPUT
%   data - level 2 data table
%
% Created by M.McFarland 2024-05-13
% Inspired by: N. Stockley
%

function data = SAP_acs_calcorr(acs,ctd)

    ai = contains(acs.data1.Properties.VariableNames,'A'); % absorption column indeces
    ci = contains(acs.data1.Properties.VariableNames,'C'); % attenuation column indeces
    acs_a = acs.data1{:,ai};
    acs_c = acs.data1{:,ci};

    % Pure water, temperature, and salinity corrections.
    % $$a=a_m-((T-T_{ref})*\Psi_T)-(S*\Psi_{Sa})-a_{cal}$$
    % $$c=c_m-((T-T_{ref})*\Psi_T)-(S*\Psi_{Sc})-c_{cal}$$
    % $$a_m$ and $$c_m$, measured a and c
    % $$T$ and $$S$, measured temperature and salinity from CTD
    % $$a_{cal}$ and $$c_{cal}$, pure water calibration
    % $$T_{ref}$, reference temperature (12 deg C)
    % $$\Psi_T$, $$\Psi_{Sa}$, $$\Psi_{Sc}$, temperature and salinity corrections
    
    load('acs_ts_corr.mat');
    
    %% Match correction constants wavelengths
    % Finds the values of the correction constants for the specific wavelengths
    % of this sensor.  Uses the calibration row value to write data from the
    % specified calibration.
    wl_a = acs.info.wavelengths_nm(:,1);
    wl_c = acs.info.wavelengths_nm(:,2);
    ts_corr = zeros(length(wl_a),4);
    for x = 1:length(wl_a)
        match_a = find(wl_a(x) == acs_ts_wavelength(:)); 
        match_c = find(wl_c(x) == acs_ts_wavelength(:)); 
        ts_corr(x,1) = acs_ts_salt_a(match_a); % corr_salt_a
        ts_corr(x,2) = acs_ts_salt_c(match_c); % corr_salt_c
        ts_corr(x,3) = acs_ts_temp_ac(match_a); % corr_temp_a
        ts_corr(x,4) = acs_ts_temp_ac(match_c); % corr_temp_c
    end
    corr_salt_a = ts_corr(:,1)';
    corr_salt_c = ts_corr(:,2)';
    corr_temp_a = ts_corr(:,3)';
    corr_temp_c = ts_corr(:,4)';

    corr_cal_a = acs.info.cal.corr_cal_a;
    % corr_salt_a = acs.info.cal.corr_salt_a';
    % corr_temp_a = acs.info.cal.corr_temp_a';
    corr_cal_c = acs.info.cal.corr_cal_c;
    % corr_salt_c = acs.info.cal.corr_salt_c';
    % corr_temp_c = acs.info.cal.corr_temp_c';
    Tref = 12; % deg C

    a_corr = acs_a - ((ctd.Temp-Tref).*corr_temp_a) - (ctd.Salinity.*corr_salt_a) - corr_cal_a;
    c_corr = acs_c - ((ctd.Temp-Tref).*corr_temp_c) - (ctd.Salinity.*corr_salt_c) - corr_cal_c;

    data = array2table([c_corr a_corr]);
    data.Properties.VariableNames = acs.data1.Properties.VariableNames;
    
    %% Correct pure water absorption
    % Applies temperature and salinity corrections to pure water
    % absorption to calculate absorption of sea water.
    % $$a_{sw}=a_w-((T_{aw}-T)*\Psi_T)-((0-S)*\Psi_{Sa})$$
    % $$a_w$, absorption of pure water
    % $$T_{aw}$, pure water absorption temperature (22 deg C)
    % $$T$ and $$S$, measured temperature and salinity from CTD
    % $$\Psi_T$ and $$\Psi_{Sa}$, temperature and salinity corrections
    
    % aw = repmat(acs.info.cal.pure_water_abs,row_a,1);
    % aw_temp = acs.info.cal.pure_water_abs_temp;
    % aw_corr = aw - ((aw_temp-ctd.Temp)*corrtemp_a) - (ctd.Salinity * corr_salt_a);

