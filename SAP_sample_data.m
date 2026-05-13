function sdat = SAP_sample_data(arc,log)

% Format and average package data for Water Sample Data archive
%
% SYNTAX: 
%   sdat = SAP_sample_data(arc,log)
%
% INPUT:
%   arc - output structure from SAP toolbox functions
%   log - log table or log file name including path if necessary (.xlsx format)
%
% OUTPUT:
%   sdat - sample data table
%   'In Situ Data.xlsx' - file written to current folder
%
% M McFarland 2025-05-27

if ischar(log) || isstring(log)
    % opts = detectImportOptions(log,'ExpectedNumVariables',23,'VariableNamesRange',1,...
    %     'DataRange','A2');
    % opts.VariableTypes(contains(opts.VariableNames,{'secchi','wind','archive','time'},...
    %     'IgnoreCase',true)) = {'char'};
    % opts.VariableTypes(contains(opts.VariableNames,{'date'},...
    %     'IgnoreCase',true)) = {'datetime'};
    % % opts.SelectedVariableNames = {'Site','Archive','Date','Time','secchi_depth_m'};
    % log = readtable(log,opts);
    log = SAP_read_log(log,{arc.num});
end

wvl = 400:4:716; % standard wavelengths
vnm = ["ID","Date","StartTime","Duration","Depth","Temp","Cond","Sal","Den","DOmgL","DOpct","pH","Secchi",...
    'apg'+string(wvl),'cpg'+string(wvl),"bp532","ChlaLH","bbp470","bbp532","bbp660",...
    "ECOcdom","ECOchl","ECOpc","C6Pcdom","C6Pchl","C6Ppe_stnd","C6Ppe_cust","C6Ppc_stnd","C6Ppc_cust",...
    'LISST'+string(1:36)];
vtyp = cell([1,length(vnm)]);
vtyp(:) = {'double'};
vtyp(contains(vnm,{'ID','StartTime','Duration','Secchi'})) = {'string'};
vtyp(contains(vnm,{'Date'})) = {'datetime'};
sdat = table('Size',[length(arc) length(vnm)],'VariableTypes',vtyp,'VariableNames',vnm);
sdat{:,:} = missing;

for m = 1:height(log)
    n = matches({arc.num},log.Archive{m}); % find matching archive
    sns = fieldnames(arc(n).sns); % sensors in this archive
    types = struct2cell(structfun(@(x) x.info.type,arc(n).sns,'uniformoutput',false))';
    
    sdat.ID(m) = [log.Project{m} '_' char(log.Date(m),'yyyyMMdd') '_' log.Site{m} '_S'];
    sdat.Date(m) = log.Date(m);
    sdat.StartTime(m) = string(log.Time(m));
    sdat.Secchi(m) = log.secchi_depth_m(m);
    
    t = find(contains(types,{'ctd'}));
    if ~ isempty(t)
        sdat.Duration(m) = max(arc(n).sns.(sns{t}).data1.Time);
        sdat.Depth(m) = mean(rmoutliers(arc(n).sns.(sns{t}).depth));
        sdat.Temp(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Temp));
        sdat.Cond(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Conductivity));
        sdat.Sal(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Salinity));
        sdat.Den(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.SigmaT));
    end

    t = find(contains(types,{'o243'}));
    if ~ isempty(t)
        sdat.DOmgL(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data2.O2Conc_mg_L));
        sdat.DOpct(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data2.O2Sat_pcnt));
    end

    t = find(contains(types,'acs'));
    if ~ isempty(t)
        sdat(m,contains(vnm,'apg')) = mean(rmoutliers(arc(n).sns.(sns{t}).apg));
        sdat(m,contains(vnm,'cpg')) = mean(rmoutliers(arc(n).sns.(sns{t}).cpg));
        sdat.bp532(m) = sdat.cpg532(m)-sdat.apg532(m);
        sdat.ChlaLH(m) = mean(rmoutliers(arc(n).sns.(sns{t}).chl_lh));
    end

    t = find(contains(types,'ecobb3'));
    if ~ isempty(t)
        sdat(m,contains(vnm,'bbp')) = mean(arc(n).sns.(sns{t}).bbp); % no remove outliers
    end

    t = find(contains(types,'c6p'));
    if ~ isempty(t)
        sdat.C6Pcdom(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.CDOM));
        sdat.C6Pchl(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Chlorophyll_a));
        sdat.C6Ppc_stnd(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Phycocyanin));
        sdat.C6Ppc_cust(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.PC_Custom));
        sdat.C6Ppe_stnd(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.Phycoerythrin));
        sdat.C6Ppe_cust(m) = mean(rmoutliers(arc(n).sns.(sns{t}).data1.PE_Custom));
    end

    t = find(contains(types,'lisst200x'));
    if ~ isempty(t)
        sdat{m,contains(vnm,'LISST')} = mean(rmoutliers(arc(n).sns.(sns{t}).SeqProc.rand.vd));
    end
end

writetable(sdat,'In Situ Data.xlsx')
