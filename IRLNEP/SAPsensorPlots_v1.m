function [sensor_plot] = SAPsensorPlots_v1(data)

% Code to plot IRLNEP package data. If one of the below sensors is absent,
% comment that section out. 

    
    m = 4;
    n = 4;

    % get the sensor names
    sensorNames = fieldnames(data.sns);
    types = struct2cell(structfun(@(x) x.info.type,data.sns,'uniformoutput',false));
    
    ctd    = sensorNames{matches(types,'ctd')};
    acs    = sensorNames{matches(types,'acs')};
    ecobb3 = sensorNames{matches(types,'ecobb3')};
%     lisst  = sensorNames{matches(types,'lisst')};
    c6p    = sensorNames{matches(types,'c6p')};
    o2    = sensorNames{matches(types,'o243')};

    t = data.sns.(ctd).data1.Time; % x axis times
    wvl=data.sns.(acs).wvl; % x axis wavelengths
    
    %% Set up figure
    figure('units','inches','position',[1 1 12 7]);
    % figTitle = strcat(data.info(1),{' '},data.info(5));
    sgtitle(data.num,'interpreter','none');

    %% CTD
    % Depth
    subplot(m,n,1);
    y=data.sns.(ctd).depth; % depth
    idx = ~isnan(y);
    plot(t(idx),y(idx),'k-');
    set(gca,'YDir','reverse');
    ylabel('Depth (m)');
    title('Depth');
    clear y idx
    
    %CTD Temp
    subplot(m,n,2);
    y=data.sns.(ctd).data1.Temp; % temp
    idx = ~isnan(y);
    plot(t(idx),y(idx),'k-');
    ylabel('Temp (\circC)');
    title('Temperature');
    clear y idx
    
    % CTD Salinity
    subplot(m,n,3);
    y=data.sns.(ctd).data1.Salinity; % salinity psu
    idx = ~isnan(y);
    plot(t(idx),y(idx),'k-');
    ylabel('Salinity (PSU)');
    title('Salinity');
    % clear x y idx

    %% Eco bb3
    
    subplot(m,n,4);
    b = data.sns.(ecobb3).bbp{:,1};
    bidx = ~isnan(b);
    g = data.sns.(ecobb3).bbp{:,2};
    gidx = ~isnan(g);
    r = data.sns.(ecobb3).bbp{:,3};
    ridx = ~isnan(r);
    
    hold on
    plot(t(bidx),b(bidx),'b-');
    plot(t(gidx),g(gidx),'g-');
    plot(t(ridx),r(ridx),'r-');
    ylabel('b_{bp} (m^{-1})')
    
    clear b g r bidx gidx ridx ecoTime
    
    %% C6P 
    
    % C6P Chl
    subplot(m,n,5);
    y = data.sns.(c6p).data1.Chlorophyll_a;
    idx = ~isnan(y);
    plot(t(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Chl-a Fluorescence');

    % C6P standard PC
    subplot(m,n,6);
    y = data.sns.(c6p).data1.Phycocyanin;
    idx = ~isnan(y);
    hold on
    plot(t(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Standard Phycocyanin');
    clear y idx

    % PC custom
    subplot(m,n,7);
    y = data.sns.(c6p).data1.PC_Custom;
    idx = ~isnan(y);
    plot(t(idx),y(idx),'m-');
    ylabel('Fluor (counts)');
    title('Custom Phycocyanin');
    clear y idx

    % C6P Standard PE
    subplot(m,n,8);
    y = data.sns.(c6p).data1.Phycoerythrin; % 
    idx = ~isnan(y);
    plot(t(idx),y(idx),'r-');
    ylabel('Fluor (counts)');
    title('Standard Phycoerytherin');
    % clear x y idx
    
    %% ACS 
    
    % ACS chl line height
    subplot(m,n,9);
    y=data.sns.(acs).chl_lh; % Chlorophyll estimate from line height
    idx = ~isnan(y);
    plot(t(idx),y(idx),'g-');
    title('acs Chl Line Height');
    ylabel('a_{pg}-chl (mg m^{-3})');
    clear y idx

    % ACS apg spectral
    subplot(m,n,10);
    y=table2array(data.sns.(acs).apg); % apg
    plot(wvl,y);
    xlim([400 730]);
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS apg outliers removed
    subplot(m,n,11);
    y=rmoutliers(data.sns.(acs).apg,'mean'); % apg
    y = table2array(y);
    % y=data.sns.(acs).data.derived.apg_PROP_RR1(:,3:end),'mean'); % apg
    plot(wvl,y);
    xlim([400 730]);
    title('acs a_{pg} outliers removed');
    ylabel('a_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral
    subplot(m,n,12);
    y=table2array(data.sns.(acs).cpg); % cpg
    plot(wvl,y);
    xlim([400 730]);
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % ACS cpg spectral outliers removed
    subplot(m,n,13);
    y=rmoutliers(data.sns.(acs).cpg,'mean'); % cpg
    y = table2array(y);
    plot(wvl,y);
    xlim([400 730]);
    title('acs c_{pg} outliers removed');
    ylabel('c_{pg} (m^{-1})');
    xlabel('Wavelength (nm)');

    % apg timeseries outliers removed
    subplot(m,n,14);
    [apg_time,idx]=rmoutliers(data.sns.(acs).apg,'mean');
    hold on
    plot(t(~idx),apg_time{:,21},'b.');
    plot(t(~idx),apg_time{:,36},'g.');
    plot(t(~idx),apg_time{:,70},'r.');
    title('acs a_{pg}');
    ylabel('a_{pg} (m^{-1})');

    % cpg time series outliers removed
    subplot(m,n,15);
    [cpg_time,idx]=rmoutliers(data.sns.(acs).cpg,'mean');
    hold on
    plot(t(~idx),cpg_time{:,21},'b.');
    plot(t(~idx),cpg_time{:,35},'g.');
    plot(t(~idx),cpg_time{:,70},'r.');
    title('acs c_{pg}');
    ylabel('c_{pg} (m^{-1})');

    % O2
    subplot(m,n,16);
    y=data.sns.(o2).data2.O2Sat_pcnt; % %
    plot(t,y);
    ylabel('% Saturation');
    title('O2 % Saturation');  

end


