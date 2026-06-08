function [sensor_plot] = IPPsensorPlots(data)
%n=1:5;
stations = [{'SB'},{'VB'},{'FP'},{'ME'},{'SLE'}];

snames=fieldnames(data)
d=data.arc001.info(5);

%mkdir sensor_plots
%NEP_path=strcat(pwd,'\sensor_plots\');

for xx=1:length(snames);
    fName=snames{xx};
 
figure('units','inches','position',[1 1 12 7]);
sgtitle(strcat(stations{xx},'_',d),'Interpreter','none');

%CTD Depth
subplot(4,4,1);
T =  array2table(data.(fName).sensors.ctd49002.data.data.ctd_binned.to6Hz);
rmT = rmmissing(T);
x=milliseconds(table2array(rmT(:,1))); % time
y=table2array(rmT(:,2)); % depth
plot(x,y,'k');
set(gca,'YDir','reverse');
ylabel('Depth (m)');
title('Depth');

%CTD Temp
subplot(4,4,2);
x=milliseconds(data.(fName).sensors.ctd49002.data.data.ctd_binned.to6Hz(:,1)); % time
y=data.(fName).sensors.ctd49002.data.data.ctd_binned.to6Hz(:,3); % temp
plot(x,y,'k');
ylabel('Temp (\circC)');
title('Temperature');

%CTD Salinity
subplot(4,4,3);
x=milliseconds(data.(fName).sensors.ctd49002.data.data.ctd_binned.to6Hz(:,1)); % time
y=data.(fName).sensors.ctd49002.data.data.ctd_binned.to6Hz(:,5); % salinity psu
plot(x,y,'k');
ylabel('Salinity (PSU)');
title('Salinity');

%eco bb3
subplot(4,4,4);

eco = array2table(data.(fName).sensors.ecobb30224.data.derived.acs030d.PROP_RR1.bbp_BB3(:,1));
rmTt = rmmissing(eco);

Tb = array2table(data.(fName).sensors.ecobb30224.data.derived.acs030d.PROP_RR1.bbp_BB3(:,3));
rmTb = rmmissing(Tb);

Tg = array2table(data.(fName).sensors.ecobb30224.data.derived.acs030d.PROP_RR1.bbp_BB3(:,4));
rmTg = rmmissing(Tg);

Tr = array2table(data.(fName).sensors.ecobb30224.data.derived.acs030d.PROP_RR1.bbp_BB3(:,5));
rmTr = rmmissing(Tr);

hold on

plot(table2array(rmTt),table2array(rmTb),'b-');
plot(table2array(rmTt),table2array(rmTg),'g-');
if rmTr {:,:} > 0;
    plot(table2array(rmTt),table2array(rmTr),'r-');
end

%legend('470','532','660','Location','best')
ylabel('b_{bp} (m^-1)');
title('EcoBB3');

%C6P Chl
subplot(4,4,5);
T = array2table(data.(fName).sensors.c6p02360114.data.fluor.ctd_binned.to6Hz);
rmT = rmmissing(T);
x=milliseconds(table2array(rmT(:,1))); % time
y=table2array(rmT(:,3)); % Chlorophyll
plot(x,y,'r');
ylabel('Fluor (counts)');
title('Chl-a Fluorescence');

%C6P standard PC
subplot(4,4,6);
y=table2array(rmT(:,5)); % 
plot(x,y,'m');
ylabel('Fluor (counts)');
title('Standard Phycocyanin');

%PC custom
subplot(4,4,7);
y=table2array(rmT(:,7));
plot(x,y,'m');
ylabel('Fluor (counts)');
title('Custom Phycocyanin');

%C6P Standard PE
subplot(4,4,8);
y=table2array(rmT(:,6)); % 
plot(x,y,'r');
ylabel('Fluor (counts)');
title('Standard Phycoerytherin');

%ACS chl line height
subplot(4,4,9);
x=milliseconds(data.(fName).sensors.acs030d.data.derived.chl_apg(:,1)); % time
y=data.(fName).sensors.acs030d.data.derived.chl_apg(:,3); % Chlorophyll estimate from line height
plot(x,y,'g');
title('acs Chl Line Height');
ylabel('a_{pg}-chl (mg m^{-3})');

%ACS apg spectral
subplot(4,4,10);
x=data.(fName).sensors.acs030d.data.corr.native.wl_a; % wvl
y=data.(fName).sensors.acs030d.data.derived.apg_PROP_RR1(:,3:end); % apg
plot(x,y);
xlim([400 730]);
title('acs a_{pg}');
ylabel('a_{pg} (m^{-1})');
xlabel('Wavelength (nm)');

%ACS apg outliers removed
subplot(4,4,11);
x=data.(fName).sensors.acs030d.data.corr.native.wl_a; % wvl
y=rmoutliers(data.(fName).sensors.acs030d.data.derived.apg_PROP_RR1(:,3:end),'mean'); % apg
plot(x,y);
xlim([400 730]);
title('acs a_{pg} outliers removed');
ylabel('a_{pg} (m^{-1})');
xlabel('Wavelength (nm)');


%ACS cpg spectral
subplot(4,4,12);
x=data.(fName).sensors.acs030d.data.corr.native.wl_c; % wvl
y=data.(fName).sensors.acs030d.data.derived.cpg(:,3:end); % cpg
plot(x,y);
xlim([400 730]);
title('acs c_{pg}');
ylabel('c_{pg} (m^{-1})');
xlabel('Wavelength (nm)');


%ACS cpg spectral outliers removed
subplot(4,4,13);
x=data.(fName).sensors.acs030d.data.corr.native.wl_c; % wvl
y=rmoutliers(data.(fName).sensors.acs030d.data.derived.cpg(:,3:end),'mean'); % cpg
plot(x,y);
xlim([400 730]);
title('acs c_{pg} outliers removed');
ylabel('c_{pg} (m^{-1})');
xlabel('Wavelength (nm)');

%apg timeseries outliers removed
subplot(4,4,14);
hold on
apg_time=data.(fName).sensors.acs030d.data.derived.apg_PROP_RR1(:,:);
new_apg_time=rmoutliers(apg_time,'mean');
plot(new_apg_time(:,1),...
new_apg_time(:,21),'b');
plot(new_apg_time(:,1),...
new_apg_time(:,36),'g');
plot(new_apg_time(:,1),...
new_apg_time(:,68),'r');
title('acs a_{pg}');
ylabel('a_{pg} (m^{-1})');

%cpg time series outliers removed
subplot(4,4,15);
hold on
cpg_time=data.(fName).sensors.acs030d.data.derived.cpg(:,:);
new_cpg_time=rmoutliers(cpg_time,'mean');
plot(new_cpg_time(:,1),...
new_cpg_time(:,21),'b');
plot(new_cpg_time(:,1),...
new_cpg_time(:,35),'g');
plot(new_cpg_time(:,1),...
new_cpg_time(:,66),'r');
title('acs c_{pg}');
ylabel('c_{pg} (m^{-1})');

%O2
subplot(4,4,16);
x=milliseconds(data.(fName).sensors.o2430035.data.corr.native.o2(:,1)); % time
y=data.(fName).sensors.o2430035.data.corr.native.o2(:,7); % %
plot(x,y);
ylabel('% Saturation');
title('O2 % Saturation');

%date=s.log_array.explog(5,1:length(xx));
%figname=strcat(stations{xx},'_',date);
%saveas(gcf,strcat(NEP_path,figname,'.fig'));

end
end