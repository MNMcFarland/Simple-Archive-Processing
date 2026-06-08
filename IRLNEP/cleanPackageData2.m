function [cleanS] = cleanPackageData(s,projectName)
% cleanPackageData
%   This script creates a clean struct of the optical package data in which
%   only the necessary final data and metadata are saved out.
%    
%   s = "s" struct saved out of IPP processing script
%   projectName = char string with name of project, ex. 'IRLNEP'
    

cleanS = struct(); % struct to save cleaned arc00x data in; needs to be similar format to what Ipa's code expects

% get fieldnames of s
fNames = fieldnames(s);
if sum(contains(fNames,'log_array')) > 0
    fNames(contains(fNames,'log_array')) = [];
end

for xx = 1:numel(fNames)

    sensorNames = fieldnames(s.(fNames{xx}).sensors);
    
    % get the sensor names 
    ctd    = sensorNames(contains(sensorNames,'ctd'));
    acs    = sensorNames(contains(sensorNames,'acs'));
    ecobb3 = sensorNames(contains(sensorNames,'ecobb3'));
%     ecobb2 = sensorNames(contains(sensorNames,'ecobb2'));
    lisst  = sensorNames(contains(sensorNames,'lisst'));
    c6p    = sensorNames(contains(sensorNames,'c6p'));
    o243   = sensorNames(contains(sensorNames,'o243'));
    
    
    % station name
    stationTemp = s.(fNames{xx}).info{1};
    dateTemp    = s.(fNames{xx}).info{5};
    dataName    = [projectName,'_',erase(dateTemp,'-'),'_',stationTemp,'_EARL'];
    dataName    = erase(dataName,' ');
    % meta
    cleanS.(dataName).station_id    = stationTemp;
    cleanS.(dataName).date          = dateTemp;
    cleanS.(dataName).strTime_local = s.(fNames{xx}).info{7};
    cleanS.(dataName).depth_m       = s.(fNames{xx}).info{22};
    cleanS.(dataName).secchi_m      = s.(fNames{xx}).info{23};
    cleanS.(dataName).procCode      = ['IPP_',char(datetime(date,'Format','yyyyMMdd'))];
    cleanS.(dataName).latLon        = [str2double(s.(fNames{xx}).info{10}),str2double(s.(fNames{xx}).info{11})];
    cleanS.(dataName).sensorNames   = sensorNames;
    % ctd
    cleanS.(dataName).ctd.header    = s.(fNames{xx}).sensors.(ctd{:}).data.data.header;
    cleanS.(dataName).ctd.data      = s.(fNames{xx}).sensors.(ctd{:}).data.data.ctd_binned.to6Hz;
    % acs
    cleanS.(dataName).acs.header.apg = s.(fNames{xx}).sensors.(acs{:}).data.a.header;
    cleanS.(dataName).acs.header.cpg = s.(fNames{xx}).sensors.(acs{:}).data.c.header;
    cleanS.(dataName).acs.header.bp  = s.(fNames{xx}).sensors.(acs{:}).data.derived.headers.bp;
    cleanS.(dataName).acs.wl_a = s.(fNames{xx}).sensors.(acs{:}).data.corr.native.wl_a;
    cleanS.(dataName).acs.wl_c = s.(fNames{xx}).sensors.(acs{:}).data.corr.native.wl_c;
    wl_bTemp = s.(fNames{xx}).sensors.(acs{:}).data.derived.headers.bp; % find wavelengths of b from header file
    wl_bTemp = wl_bTemp(3:end,1);
    for yy = 1:numel(wl_bTemp)
        wl_b(yy) = str2double(wl_bTemp{yy}(4:end));
    end
    cleanS.(dataName).acs.wl_b = wl_b';
    cleanS.(dataName).acs.scat_corr  = s.(fNames{xx}).sensors.(acs{:}).data.derived.scat_corr;
    cleanS.(dataName).acs.at         = s.(fNames{xx}).sensors.(acs{:}).data.derived.at;
    cleanS.(dataName).acs.ct         = s.(fNames{xx}).sensors.(acs{:}).data.derived.ct;
    cleanS.(dataName).acs.apg        = s.(fNames{xx}).sensors.(acs{:}).data.derived.apg_PROP_RR1;
    cleanS.(dataName).acs.cpg        = s.(fNames{xx}).sensors.(acs{:}).data.derived.cpg;
    cleanS.(dataName).acs.bp         = s.(fNames{xx}).sensors.(acs{:}).data.derived.bp_PROP_RR1;
    % ecobb3
    cleanS.(dataName).ecobb3.header  = s.(fNames{xx}).sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.headers.bp;
    cleanS.(dataName).ecobb3.scat_corr = ['PROP_RR1 and absorption corrected'];
    cleanS.(dataName).ecobb3.bbp     = s.(fNames{xx}).sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3;
    % ecobb2
%     if isempty('ecobb2')
%         cleanS.(dataName).ecobb2.header  = s.(fNames{xx}).sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.headers.bp;
%         cleanS.(dataName).ecobb2.scat_corr = ['PROP_RR1 and absorption corrected'];
%         cleanS.(dataName).ecobb2.bbp     = s.(fNames{xx}).sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3;
%     end
    % c6p
%    cleanS.(dataName).c6p.header     = s.(fNames{xx}).sensors.(c6p{:}).data.fluor.header;
%    cleanS.(dataName).c6p.data       = s.(fNames{xx}).sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz;
    % lisst
    if isempty('lisst')
        cleanS.(dataName).lisst.header   = ["rand = random particle shape inversion";"spher = spherical particle shape inversion"];
        cleanS.(dataName).lisst.rand     = s.(fNames{xx}).sensors.(lisst{:}).data.data.sequoiaProcessing.rand;
        cleanS.(dataName).lisst.spher    = s.(fNames{xx}).sensors.(lisst{:}).data.data.sequoiaProcessing.spher;
    end
    % o2
    cleanS.(dataName).o2.header      = s.(fNames{xx}).sensors.(o243{:}).data.corr.native.header;
    cleanS.(dataName).o2.data        = s.(fNames{xx}).sensors.(o243{:}).data.corr.native.o2;

end





end

