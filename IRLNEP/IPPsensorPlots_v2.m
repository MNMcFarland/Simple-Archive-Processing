function [sensor_plot] = IPPsensorPlots_v2(data)

% Code to plot IRLNEP package data. If one of the below sensors is absent,
% comment that section out. 


    %% Set up figure
    figure('units','inches','position',[1 1 12 7]);
    figTitle = strcat(data.info(1),{' '},data.info(5));
    sgtitle(figTitle,'interpreter','none');

    %% CTD
    % Depth
    subplot(4,4,1);
    x=milliseconds(data.sensors.ctd49002.data.data.ctd_binned.to6Hz(:,1)); % time
    y=data.sensors.ctd49002.data.data.ctd_binned.to6Hz(:,2); % depth
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    set(gca,'YDir','reverse');
    ylabel('Depth (m)');
    title('Depth');
    clear y idx
    
    %CTD Temp
    subplot(4,4,2);
    y=data.sensors.ctd49002.data.data.ctd_binned.to6Hz(:,3); % temp
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    ylabel('Temp (\circC)');
    title('Temperature');
    clear y idx
    
    % CTD Salinity
    subplot(4,4,3);
    y=data.sensors.ctd49002.data.data.ctd_binned.to6Hz(:,5); % salinity psu
    idx = ~isnan(y);
    plot(x(idx),y(idx),'k-');
    ylabel('Salinity (PSU)');
    title('Salinity');
    clear x y idx

    %% Eco bb3
    
    subplot(4,4,4);
    ecoTime = milliseconds(data.sensors.ecobb30224.data.derived.acs032.PROP_RR1.bbp_BB3(:,1));
    b = data.sensors.ecobb30224.data.derived.acs032.PROP_RR1.bbp_BB3(:,3);
    bidx = ~isnan(b);
    g = data.sensors.ecobb30224.data.derived.acs032.PROP_RR1.bbp_BB3(:,4);
    gidx = ~isnan(g);
    r = data.sensors.ecobb30224.data.derived.acs032.PROP_RR1.bbp_BB3(:,5);
    ridx = ~isnan(r);
    
    hold on
    plot(ecoTime(bidx),b(bidx),'b-');
    plot(ecoTime(gidx),g(gidx),'g-');
    plot(ecoTime(ridx),r(ridx),'r-');
    ylabel('b_{bp} (m^{-1})')
    
    clear b g r bidx gidx ridx ecoTime
    
    %% C6P 
    
    % C6P Chl
    subplot(4,4,5);
    x = milliseconds(data.sensors.c6p02360114.data.fluor.ctd_binned.to6Hz(:,1));
    y = data.sensors.c6p02360114.data.fluor.ctd_binned.to6Hz(:,3);
    idx = ~isnan(y);
    plot(x(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Chl-a Fluorescence');

    % C6P standard PC
    subplot(4,4,6);
    y = data.sensors.c6p02360114.data.fluor.ctd_binned.to6Hz(:,5);
    idx = ~isnan(y);
    hold on
    plot(x(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Standard Phycocyanin');
    clear y idx

    % PC custom
    subplot(4,4,7);
    y = data.sensors.c6p02360114.data.fluor.ctd_binned.to6Hz(:,7);
    idx = ~isnan(y);
    plot(x(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Custom Phycocyanin');
    clear y idx

    % C6P Standard PE
    subplot(4,4,8);
    y = data.sensors.c6p02360114.data.fluor.ctd_binned.to6Hz(:,6); % 
    idx = ~isnan(y);
    plot(x(idx),y(idx),'r-');
    ylabel('Fluor (counts)');
    title('Standard Phycoerytherin');
    clear x y idx
    
    %% ACS 
    
    % ACS chl line height
    subplot(4,4,9);
    x=milliseconds(data.sensors.acs032.data.derived.chl_apg(:,1)); % time
    y=data.sensors.acs032.data.derived.chl_apg(:,3); % Chlorophyll estimate from line height
    idx = ~isnan(y);
    plot(x(idx),y(idx),'g-');
    title('acs Chl Line Height');
    ylabel('a_{pg}-chl (mg m^{-3})');
    clear y idx

    % ACS apg spectral
    subplot(4,4,10);
    x=data.sensors.acs032.data.corr.native.wl_a; % wvl
    y=data.sensors.acs032.data.derived.apg_PROP_RR1(:,3:end); % apg
    plot(x,y);
    xlim([400 730]);
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS apg outliers removed
    subplot(4,4,11);
    x=data.sensors.acs032.data.corr.native.wl_a; % wvl
    y=rmoutliers(data.sensors.acs032.data.derived.apg_PROP_RR1(:,3:end),'mean'); % apg
    plot(x,y);
    xlim([400 730]);
    title('acs a_{pg} outliers removed');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral
    subplot(4,4,12);
    x=data.sensors.acs032.data.corr.native.wl_c; % wvl
    y=data.sensors.acs032.data.derived.cpg(:,3:end); % cpg
    plot(x,y);
    xlim([400 730]);
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral outliers removed
    subplot(4,4,13);
    x=data.sensors.acs032.data.corr.native.wl_c; % wvl
    y=rmoutliers(data.sensors.acs032.data.derived.cpg(:,3:end),'mean'); % cpg
    plot(x,y);
    xlim([400 730]);
    title('acs c_{pg} outliers removed');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % apg timeseries outliers removed
    subplot(4,4,14);
    apg_time=rmoutliers(data.sensors.acs032.data.derived.apg_PROP_RR1,'mean');
    x = milliseconds(apg_time(:,1));
    hold on
    plot(x,apg_time(:,21),'b.');
    plot(x,apg_time(:,36),'g.');
    plot(x,apg_time(:,68),'r.');
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');

    % cpg time series outliers removed
    subplot(4,4,15);
    cpg_time=rmoutliers(data.sensors.acs032.data.derived.cpg,'mean');
    x = milliseconds(cpg_time(:,1));
    hold on
    plot(x,cpg_time(:,21),'b.');
    plot(x,cpg_time(:,35),'g.');
    plot(x,cpg_time(:,66),'r.');
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');

    % O2
    subplot(4,4,16);
    x=milliseconds(data.sensors.o2430035.data.corr.native.o2(:,1)); % time
    y=data.sensors.o2430035.data.corr.native.o2(:,7); % %
    plot(x,y);
    ylabel('% Saturation');
    title('O2 % Saturation');  

end


