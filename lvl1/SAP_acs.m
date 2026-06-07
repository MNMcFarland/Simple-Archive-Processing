%% SAP_acs
%
% SAP_acs032 reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "acs032".
%
% USAGE: acs = SAP_acs(cfg)
%
% INPUT
%   cfg - corresponding row from the configuration table as a structure
%   array with scalar fields
%
% OUTPUT
%   acs032 - structure with data and sensor information from specified file
%
% M. McFarland 2024-05-17
% Inspired by: N. Stockley
%
% 2024-08-12... Edited by Z. Wistort, added selection of acs DEV creation date
% in switch case statement as serial number of the device is non-unqiue to DEV
% files of same device, example: acs030c and acs030d DEV files have same serial
% number: 5300001E

function acs = SAP_acs(cfg)


%% Sensor information
% Writes information about the sensor to the structure field. This
% information will be called in later processing.

% import instrument specific .DEV file
dev  = SAP_importDev(cfg.dev);
dev_serialNum = dev.VarName1{2};
aWvl = dev.VarName2(11:end-1);
cWvl = dev.VarName1(11:end-1);

acs.info.type = 'acs';
switch dev_serialNum
    case '5300001E'
        dateTemp = dev{4,1}{:}; % cell with date info in DEV file
        [x1,x2] = regexp(dev{4,1}{:},'[0-9]\d?\/[0-9]\d?\/[0-9][0-9]\d?\d?'); % regex DEV file date
        dateTemp = dateTemp(x1:x2);
        if strcmp(dateTemp,'11/15/17')
            acs.info.sensor_id = 'acs030c';
        elseif strcmp(dateTemp,'10/31/2022')
            acs.info.sensor_id = 'acs030d';
        end

    case '5300001F' %added by ipa
       acs.info.sensor_id = 'acs031c';
    case '53000020'
        acs.info.sensor_id = 'acs032';        
    otherwise
        acs.info.sensor_id = 'unknown'; 
end

acs.info.pathlength_m = str2double(dev.VarName1(7));
acs.info.num_wl = str2double(dev.VarName1(8));
acs.info.timeoffset = cfg.timeoffset;
acs.info.depthoffset = cfg.depthoffset;
acs.info.calrow = cfg.calrow;
acs.info.dev = cfg.dev;
acs.info.mode = cfg.mode;
acs.info.wavelengths_nm = cell2mat([cellfun(@(x) str2double(x(2:end)),aWvl,'UniformOutput',false),...
                                    cellfun(@(x) str2double(x(2:end)),cWvl,'UniformOutput',false)]);
acs.info.wvl_c = acs.info.wavelengths_nm(:,2);
acs.info.wvl_a = acs.info.wavelengths_nm(:,1);

%% Import data
% Imports data from extracted archive file.
pth = [cfg.path filesep cfg.fname];
data = importdata(pth);
acs.info.text_data = data.textdata;
data = data.data;

%% data array
% Writes data into a structure field for this sensor. 
acs.info.header(:,1) = [{'Time'};aWvl;cWvl];
acs.info.header(:,2) = [{'ms'},repelem({'1/m'},2*acs.info.num_wl)];
acs.raw = data(:,1:(2*acs.info.num_wl+1));

%% Load calibration/correction data
% Loads the sensor calibration data into the function workspace. Also loads
% required correction constants.
calFileName = [acs.info.sensor_id,'_cal.mat'];
cal = load(calFileName);
acs.info.cal.date = cal.([acs.info.sensor_id,'_corr']){cfg.calrow,1}; 
acs.info.cal.corr_cal_a = cal.([acs.info.sensor_id,'_corr']){cfg.calrow,3};
acs.info.cal.corr_cal_c = cal.([acs.info.sensor_id,'_corr']){cfg.calrow,4};

%% Check maximum internal temperature
% Locates the minimum and maximum internal temperature recorded in the data
% Obtains the minimum and maximum internal temperature from the sensor
% device file temperature calibration, based on the device file used to
% collect the data. 
acs.info.itemp.itemp_header = {'Time','ms';'Internal temperature','C'};
acs.info.itemp.data = [data(:,1) data(:,2*acs.info.num_wl+5)];
acs.info.itemp.min_itemp = min(acs.info.itemp.data(:,2));
acs.info.itemp.max_itemp = max(acs.info.itemp.data(:,2));

