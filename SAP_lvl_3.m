% Simple Archive Processing level 3
%
% Calculates derived parameters for each sensor 
% in each archive using instrument type
% specific functions (SAP_*_proc.m)
%
% USAGE: arc = SAP_lvl_3(arc)
%
% INPUT
%   arc - data structure array
%
% OUTPUT
%   arc - data structure array
%
% M. McFarland 2024-05-13
% Inspired by: N. Stockley

function arc = SAP_lvl_3(arc)

for m = 1:numel(arc) % loop through archives
    sensors = fieldnames(arc(m).sns);
    types = struct2cell(structfun(@(x) x.info.type,arc(m).sns,'uniformoutput',false))';
    modes = struct2cell(structfun(@(x) x.info.mode,arc(m).sns,'uniformoutput',false))';

    % Process sensors in this order
    % ac filtered
    for n = find(contains(types,{'acs','ac9'}) & contains(modes,'filter'))
        [wvl,ag] = SAP_ac_proc(arc(m).sns.(sensors{n}));
        arc(m).sns.(sensors{n}).wvl = wvl;
        arc(m).sns.(sensors{n}).ag = ag;
        % arc(m).sns.(sensors{n}).ag_slope = ag_slope;
    end

    % ac total
    %for n = find(contains(types,{'acs','ac9'}) & contains(modes,'total'))
 
    for n = find(contains(types,{'acs','ac9','acs032'}) & contains(modes,'total'))
        [wvl,apg,cpg,bp,chl_lh] = SAP_ac_proc(arc(m).sns.(sensors{n}));
        arc(m).sns.(sensors{n}).wvl = wvl;
        arc(m).sns.(sensors{n}).apg = apg;
        arc(m).sns.(sensors{n}).cpg = cpg;
        arc(m).sns.(sensors{n}).bp = bp;
        arc(m).sns.(sensors{n}).chl_lh = chl_lh;

        % compute bp if ag data exists - not tested yet
        idx = find(contains(types,{'acs','ac9','acs032'}) & strcmp(modes,'filter'),1);
        if ~isempty(idx)
            ag = table2array(arc(m).sns.(sensors{idx}).ag);
            arc(m).sns.(sensors{n}).ap = apg - ag;
            arc(m).sns.(sensors{n}).cp = cpg - ag;
            vnm = string(arc(m).(sensors{n}).wvl);
            arc(m).sns.(sensors{n}).ap.Properties.VariableNames = 'ap' + vnm;
            arc(m).sns.(sensors{n}).cp.Properties.VariableNames = 'cp' + vnm;
        end
    end

    % bb
    %for n = find(contains(types,{'ecobb3','imosc6'}))
    for n = find(contains(types,{'ecobb3','ecofl3','imosc6'}))
        idx = find(strcmp(types,'ctd'),1);
        ctd = arc(m).sns.(sensors{idx}).data1;
        idx = find(contains(types,{'acs','ac9'}) & strcmp(modes,'total'),1);
        if isempty(idx)
            [beta_t,beta_p,bbt,bbp,bbpbp] = SAP_bb_proc(arc(m).sns.(sensors{n}),ctd);
        elseif ~isempty(idx)
            ac = arc(m).sns.(sensors{idx});
            [beta_t,beta_p,bbt,bbp,bbpbp] = SAP_bb_proc(arc(m).sns.(sensors{n}),ctd,ac);
        end
        arc(m).sns.(sensors{n}).beta_t = beta_t; 
        arc(m).sns.(sensors{n}).beta_p = beta_p;
        arc(m).sns.(sensors{n}).bbt = bbt;
        arc(m).sns.(sensors{n}).bbp = bbp;
        arc(m).sns.(sensors{n}).bbpbp = bbpbp;
    end

    % LISST
    for n = find(contains(types,{'lisst200x'}))
        zsc = arc(m).sns.(sensors{n}).info.cal.zsc;
        fzs = arc(m).sns.(sensors{n}).info.cal.fzs;
        dcal = arc(m).sns.(sensors{n}).info.cal.dcal;
        VCC = arc(m).sns.(sensors{n}).info.cal.VCC;

        % correct scattering
        lisstDataRaw  = table2array(arc(m).sns.(sensors{n}).data1);
        lisstDataProc = getscat_L200X_ZPWEdit(lisstDataRaw,zsc,fzs,dcal,VCC);
        
        % Invert particle size concentrations using corrected scattering (cscat)
        % vd parameter is the volume distribution in uL/L
        % for each size bin center in dias (microns)
        % Example from Sequoia
        % [vd, dias] = invert_L200X(Cscat,Random,Sharpen,ShowProgressBar)
        [rand_vd, rand_dias]   = invert_L200X(lisstDataProc.cscat,1,1,0); % random approximation
        [spher_vd, spher_dias] = invert_L200X(lisstDataProc.cscat,0,1,0); % spherical approximation
        
        arc(m).sns.(sensors{n}).SeqProc.cscat = lisstDataProc.cscat;
        arc(m).sns.(sensors{n}).SeqProc.rand.vd = rand_vd;
        arc(m).sns.(sensors{n}).SeqProc.rand.dias = rand_dias;
        arc(m).sns.(sensors{n}).SeqProc.spher.vd = spher_vd;
        arc(m).sns.(sensors{n}).SeqProc.spher.dias = spher_dias;
    end
end
