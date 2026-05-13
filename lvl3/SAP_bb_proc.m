% SAP_bb_proc
%
% Level 3 data processing for bb sensors
% applies corrections and computes bb.
% corrects for abosrption and computes bb/b if ac data is provided.
% Requires sw_scat.m
%
% USAGE: [beta_t,beta_p,bbt,bbp,bbp_bp] = SAP_bb_proc(bb,ctd,acs)
%
% INPUT
%   bb - substructure of bb sensor from arc structure array
%   ctd - time synchronized (level 1) ctd data table
%   acs - (optional) acs sensor substructure with level 3 data
%
% OUTPUT
%   beta_t - VSF at specified angle and wavelength including modeled seawater scattering
%   beta_p - VSF at specified angle and wavelength particulate and total
%   bbt - total backscatter including modeled seawater
%   bbp - particulate backscatter including modeled seawater
%   bbp_bb - backscatter to total scatter ratio
%
% M. McFarland 2024-05-13
% Inspired by: N. Stockley


function [beta_t,beta_p,bbt,bbp,bbp_bp] = SAP_bb_proc(bb,ctd,ac)

wvl = bb.info.centroid_lambda_nm;
theta = bb.info.centroid_theta_deg;
chi = bb.info.chi_factor;
pln = bb.info.pathlength_m; % eco_l

beta_l2 = table2array(bb.data2); % level 2 data
beta_sw = zeros(size(beta_l2));
b_sw = zeros(size(beta_l2));
for m = 1:size(beta_l2,1)
    Tc = ctd.Temp(m);
    S = ctd.Salinity(m);
    [beta_sw(m,:),b_sw(m,:)] = sw_scat(wvl,theta,Tc,S); 
end

if nargin==3
    % Interpolate apg and bp to match bb wavelengths
    apg_eco = interp1(ac.wvl,table2array(ac.apg)',wvl,'linear','extrap')';
    bp_eco = interp1(ac.wvl,table2array(ac.bp)',wvl,'linear','extrap')';

    beta_t = beta_l2 .* exp(pln.*apg_eco);
    beta_p = beta_t - beta_sw;
    bbp = ((2*pi).*beta_p) .* chi;
    bbt = bbp + (b_sw/2); 
    bbp_bp = bbp./bp_eco;

    % Bulk refractive index
    if isfield(ac,'cp_slope')
        cp_slope = ac.cp_slope;
        np = zeros(length(cp_slope),size(bbp_bp,2));
        for w = 1:size(bbp_bp,2)
            np(:,w) = 1+((bbp_bp(:,w).^(0.5377+(0.4867*((-cp_slope).^2)))).*((1.4676+((2.295*((-cp_slope).^2)))+((2.3113*((-cp_slope).^4))))));
        end
    end
else
    % no total ac data available
    beta_t = beta_l2;
    beta_p = beta_t - beta_sw;
    bbp = ((2*pi).*beta_p).*chi; % particulate bb without a correction
    bbt = bbp + (b_sw/2); % total bb
    bbp_bp = [];
end

vnm = bb.data2.Properties.VariableNames;
beta_t = array2table(beta_t,'VariableNames',replace(vnm,'beta','beta_t'));
beta_p = array2table(beta_p,'VariableNames',replace(vnm,'beta','beta_p'));
bbt = array2table(bbt,'VariableNames',replace(vnm,'beta','bbt'));
bbp = array2table(bbp,'VariableNames',replace(vnm,'beta','bbp'));
if ~isempty(bbp_bp)
    bbp_bp = array2table(bbp_bp,'VariableNames',replace(vnm,'beta','bbp_bp'));
end

