function [sensor_plot] = IPPsensorPlots_v4(data)

% Code to plot IRLNEP package data. If one of the below sensors is absent,
% comment that section out. 

    
    m = 3;
    n = 4;

    % get the sensor names
    sensorNames = fieldnames(data.sensors);
    
    ctd    = sensorNames(contains(sensorNames,'ctd'));
    acs    = sensorNames(contains(sensorNames,'acs'));
    ecobb3 = sensorNames(contains(sensorNames,'ecobb3'));
%     lisst  = sensorNames(contains(sensorNames,'lisst'));
%    c6p    = sensorNames(contains(sensorNames,'c6p'));
    o2    = sensorNames(contains(sensorNames,'o2'));
    
    
    %% Set up figure
    figure('units','inches','position',[1 1 12 7]);
    figTitle = strcat(data.info(1),{' '},data.info(5));
    sgtitle(figTitle,'interpreter','none');

    %% CTD
    % Depth
    subplot(m,n,1);
    x=milliseconds(data.sensors.(ctd{:}).data.data.ctd_binned.to6Hz(:,1)); % time
    y=data.sensors.(ctd{:}).data.data.ctd_binned.to6Hz(:,2); % depth
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    set(gca,'YDir','reverse');
    ylabel('Depth (m)');
    title('Depth');
    clear y idx
    
    %CTD Temp
    subplot(m,n,2);
    y=data.sensors.(ctd{:}).data.data.ctd_binned.to6Hz(:,3); % temp
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    ylabel('Temp (\circC)');
    title('Temperature');
    clear y idx
    
    % CTD Salinity
    subplot(m,n,3);
    y=data.sensors.(ctd{:}).data.data.ctd_binned.to6Hz(:,5); % salinity psu
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    ylabel('Salinity (PSU)');
    title('Salinity');
    clear x y idx

    %% Eco bb3
    
    subplot(m,n,4);
    ecoTime = milliseconds(data.sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3(:,1));
    b = data.sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3(:,3);
    bidx = ~isnan(b);
    g = data.sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3(:,4);
    gidx = ~isnan(g);
    r = data.sensors.(ecobb3{:}).data.derived.(acs{:}).PROP_RR1.bbp_BB3(:,5);
    ridx = ~isnan(r);
    
    hold on
    plot(ecoTime(bidx),b(bidx),'b-');
    plot(ecoTime(gidx),g(gidx),'g-');
    plot(ecoTime(ridx),r(ridx),'r-');
    ylabel('b_{bp} (m^{-1})')
    
    clear b g r bidx gidx ridx ecoTime
    
%     %% C6P 
%     
%     % C6P Chl
%     subplot(m,n,5);
%     x = milliseconds(data.sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz(:,1));
%     y = data.sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz(:,3);
%     idx = ~isnan(y);
%     plot(x(idx),y(idx),'m-');
%     ylabel('Fluor (counts)');
%     title('Chl-a Fluorescence');
% 
%     % C6P standard PC
%     subplot(m,n,6);
%     y = data.sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz(:,5);
%     idx = ~isnan(y);
%     hold on
%     plot(x(idx),y(idx),'m-');
%     ylabel('Fluor (counts)');
%     title('Standard Phycocyanin');
%     clear y idx
% 
%     % PC custom
%     subplot(m,n,7);
%     y = data.sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz(:,7);
%     idx = ~isnan(y);
%     plot(x(idx),y(idx),'m-');
%     ylabel('Fluor (counts)');
%     title('Custom Phycocyanin');
%     clear y idx
% 
%     % C6P Standard PE
%     subplot(m,n,8);
%     y = data.sensors.(c6p{:}).data.fluor.ctd_binned.to6Hz(:,6); % 
%     idx = ~isnan(y);
%     plot(x(idx),y(idx),'r-');
%     ylabel('Fluor (counts)');
%     title('Standard Phycoerytherin');
%     clear x y idx
    
    %% ACS 
    
    % ACS chl line height
    subplot(m,n,5);
    x=milliseconds(data.sensors.(acs{:}).data.derived.chl_apg(:,1)); % time
    y=data.sensors.(acs{:}).data.derived.chl_apg(:,3); % Chlorophyll estimate from line height
    idx = ~isnan(y);
    plot(x(idx),y(idx),'g-');
    title('acs Chl Line Height');
    ylabel('a_{pg}-chl (mg m^{-3})');
    clear y idx

    % ACS apg spectral
    subplot(m,n,6);
    x=data.sensors.(acs{:}).data.corr.native.wl_a; % wvl
    y=data.sensors.(acs{:}).data.derived.apg_PROP_RR1(:,3:end); % apg
    plot(x,y);
    xlim([400 730]);
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS apg outliers removed
    subplot(m,n,7);
    x=data.sensors.(acs{:}).data.corr.native.wl_a; % wvl
    y=rmoutliers(data.sensors.(acs{:}).data.derived.apg_PROP_RR1(:,3:end),'mean'); % apg
    plot(x,y);
    xlim([400 730]);
    title('acs a_{pg} outliers removed');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral
    subplot(m,n,8);
    x=data.sensors.(acs{:}).data.corr.native.wl_c; % wvl
    y=data.sensors.(acs{:}).data.derived.cpg(:,3:end); % cpg
    plot(x,y);
    xlim([400 730]);
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral outliers removed
    subplot(m,n,9);
    x=data.sensors.(acs{:}).data.corr.native.wl_c; % wvl
    y=rmoutliers(data.sensors.(acs{:}).data.derived.cpg(:,3:end),'mean'); % cpg
    plot(x,y);
    xlim([400 730]);
    title('acs c_{pg} outliers removed');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % apg timeseries outliers removed
    subplot(m,n,10);
    apg_time=rmoutliers(data.sensors.(acs{:}).data.derived.apg_PROP_RR1,'mean');
    x = milliseconds(apg_time(:,1));
    hold on
    plot(x,apg_time(:,21),'b.');
    plot(x,apg_time(:,36),'g.');
    plot(x,apg_time(:,68),'r.');
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');

    % cpg time series outliers removed
    subplot(m,n,11);
    cpg_time=rmoutliers(data.sensors.(acs{:}).data.derived.cpg,'mean');
    x = milliseconds(cpg_time(:,1));
    hold on
    plot(x,cpg_time(:,21),'b.');
    plot(x,cpg_time(:,35),'g.');
    plot(x,cpg_time(:,66),'r.');
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');

    % O2
    subplot(m,n,12);
    x=milliseconds(data.sensors.(o2{:}).data.corr.native.o2(:,1)); % time
    y=data.sensors.(o2{:}).data.corr.native.o2(:,7); % %
    plot(x,y);
    ylabel('% Saturation');
    title('O2 % Saturation');  

end


