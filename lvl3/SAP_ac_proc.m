% ac device Simple Archive Processing level 3
%
% Does ac scatter corrections and calculates derived parameters
% interpolates all data to a standard set of 80 wavelengths (400:4:716)
%
% USAGE
%   [wvl,apg,cpg,bp,chl_lh] = SAP_ac_proc(ac); % for mode = total
%   [wvl,ag] = SAP_ac_proc(ac); % for mode = filter
%
% INPUT
%   ac - ac sensor substructure within arc array including
%       sensor information and data
%
% OUTPUT (variable depending on mode)
%   wvl - interpolated wavelengths (both modes)
%   apg - data table if mode = total
%   cpg - data table if mode = total
%   bp - data table if mode = total
%   chl_lh - chlorphyll concentrations from absorption line height method
%       if mode = total
%   ag - data table if mode = filter
% 
% M. McFarland 2024-05-13

function varargout = SAP_ac_proc(ac)

ai = contains(ac.data2.Properties.VariableNames,'a','IgnoreCase',true); % absorption column indeces
ci = contains(ac.data2.Properties.VariableNames,'c','IgnoreCase',true); % attenuation column indeces
am = ac.data2{:,ai}; % measured a values
cm = ac.data2{:,ci}; % measured c values
am(am<0) = 0;
cm(cm<0) = 0;
% wvl = ac.info.wvl_a; % use a wavelengths
wvl = 400:4:716; % standard wavelengths
varargout{1} = wvl;
vnm = string(wvl);

% interpolate a and c to common wavelengths
cm = interp1(ac.info.wvl_c,cm',wvl)';
am = interp1(ac.info.wvl_a,am',wvl)';

if strcmpi(ac.info.mode,'total')

    % subtract ag first if it exists?
    % if isfield(ac,'ag'); ap = am - ac.ag; end

    % scattering correction PROP_RR1
    [~,i715] = min(abs(wvl-715)); % find index of wavelength closest to 715 nm
    a715 = 0.212*am(:,i715).^1.135; % RRottgers etal 2013 (only appropriate for apg)
    bm = cm/0.56 - am;
    b715 = cm(:,i715)/0.56 - a715;
    apg = am - (am(:,i715)-a715) .* (bm./b715); % proportional correction
    apg = array2table(apg);
    apg.Properties.VariableNames = 'apg' + vnm;
    varargout{2} = apg;

    % cpg - just copied from data2
    cpg = array2table(cm);
    cpg.Properties.VariableNames = 'cpg' + vnm;
    varargout{3} = cpg;

    % calculate bp
    bp = cm - apg;
    bp.Properties.VariableNames = 'bp' + vnm;
    varargout{4} = bp;

    % calculate chlorophyll by absorption line height method
    % this is not right, should be calculated on ap not apg
    [~,i676] = min(abs(wvl-676));
    [~,i650] = min(abs(wvl-650));
    astar = 0.0108; % chlorophyll specific absorption at 676 nm (m^2/mg_chla)
    abl = ((apg{:,i715}-apg{:,i650})/(715-650)) .* (676-650) + apg{:,i650}; % baseline absorption
    alh = apg{:,i676} - abl; % absorption line height
    chl_lh = alh/astar; % chlorophyll a concentration in mg/m^3
    varargout{5} = chl_lh;

    % cpg slope - fails to converge too frequently
    % wli = wvl>=412 & wvl<=676;
    % cpg_slope = zeros(height(cpg),1);
    % for m = 1:height(cpg)
    %     est = fitpow(wvl(wli),cpg{m,wli});
    %     cpg_slope(m) = est(3);
    % end

elseif strcmpi(ac.info.mode,'filter')
    ag = array2table(am); % negatives removed
    ag.Properties.VariableNames = 'ag' + vnm;
    varargout{2} = ag;

    % ag slope fit between 412 and 650 - frequently fails to converge
    % wli = wvl>=412 & wvl<=650;
    % ag_slope = zeros(height(ag),1);
    % for m = 1:height(ag)
    %     est = fitexp(wvl(wli),ag{m,wli});
    %     ag_slope(m) = est(3);
    % end
    % varargout{3} = ag_slope;

end


