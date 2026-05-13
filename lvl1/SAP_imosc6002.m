%% SAP_ecoimosc6002
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "ecoimosc6002"
%
% USAGE: ecoimosc6002 = SAP_ecoimosc6002(cfg)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT
%   ecoimosc6002 - struct array with data and sensor information
%
% M. McFarland 2024-05-20
% Inspired by: N. Stockley
%

%% Declare function
function ecoimosc6002 = SAP_imosc6002(cfg)


%% Sensor information
% Writes information about the sensor to the structure field. This
% information will be called in later processing.
ecoimosc6002.info.type = 'imosc6'; % category for level 2 processing
ecoimosc6002.info.sensor_id = 'imosc6002';
ecoimosc6002.info.build_date = '2016-09-28';
ecoimosc6002.info.depth_rating_m = '300';
ecoimosc6002.info.centroid_theta_deg = [121.6 121.6 121.6 121.6 121.6 121.6];
ecoimosc6002.info.centroid_lambda_nm = [365 405 430 470 530 660];
ecoimosc6002.info.pathlength_m = [0.0088 0.0088 0.0088 0.0088 0.0088 0.0088];
ecoimosc6002.info.chi_factor = [1.0854 1.0854 1.0854 1.0854 1.0854 1.0854];
ecoimosc6002.info.timeoffset = cfg.timeoffset;
ecoimosc6002.info.depthoffset = cfg.depthoffset;
ecoimosc6002.info.calrow = cfg.calrow;
ecoimosc6002.info.mode = cfg.mode;

%% Import data
% Imports data from extracted archive file and formats it correctly.
pth = [cfg.path filesep cfg.fname];
fid = fopen(pth);
data = textscan(fid,'%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n');
fclose(fid);
data = cell2mat(data);

%% Scattering data array
% Writes data and the information entered in LOG_ARRAY.ARCLOG into a
% structure field for this sensor. Uses the calibration row value to write
% data from the specified calibration. Also writes values previously
% calculated in this function.
ecoimosc6002.info.header = {'Time','ms';...
    'beta365','counts';'beta405','counts';'beta430','counts';...
    'beta470','counts';'beta530','counts';'beta660','counts'};
ecoimosc6002.raw = [data(:,1) data(:,3:3:18)];

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('imosc6002_cal.mat') %#ok<*LOAD>
ecoimosc6002.info.cal.date = ecoimosc6002_cal{cfg.calrow,1}; %#ok<*IDISVAR,USENS>
ecoimosc6002.info.cal.scaling_factor = ecoimosc6002_cal{cfg.calrow,5};
ecoimosc6002.info.cal.dark_offset = ecoimosc6002_cal{cfg.calrow,6};

%% Internal time array
% Writes DH4 time and internal time data and the information entered in
% LOG_ARRAY.ARCLOG into a structure field for this sensor.
ecoimosc6002.info.itime.header = {'Time','ms';'Internal time','ms'};
ecoimosc6002.info.itime.raw = data(:,1:2);

%% Signal reference array
% Writes time and signal reference data and the information entered in
% LOG_ARRAY.ARCLOG into a structure field for this sensor.
ecoimosc6002.info.sigref.header = {'Time','ms';...
    'beta365_ref','counts';'beta405_ref','counts';...
    'beta430_ref','counts';'beta470_ref','counts';...
    'beta530_ref','counts';'beta660_ref','counts'};
ecoimosc6002.info.sigref.raw = [data(:,1) data(:,4:3:19)];

%% Signal temperature array
% Writes time and signal temperature data and the information entered in
% LOG_ARRAY.ARCLOG into a structure field for this sensor.
ecoimosc6002.info.sigtemp.header = {'Time','ms';...
    'beta365_temp','deg C';'beta405_temp','deg C';...
    'beta430_temp','deg C';'beta470_temp','deg C';...
    'beta530_temp','deg C';'beta660_temp','deg C'};
ecoimosc6002.info.sigtemp.raw = [data(:,1) data(:,5:3:20)];

% %% Calculate sampling rate (Hz)
% % Calculates the data sampling rate by:
% %
% % $$sampling_-rate = \frac{total_-samples}{\frac{end_-time-start_-time}{1000}}$$
% %
% % The elapsed time must be divided by 1000 to convert from data time in
% % milliseconds to seconds. The rate will be approximate when any data
% % interruption occurs, resulting in elapsed time without samples.
% elapsed_time = (data(end,1) - data(1,1))/1000;
% total_samples = length(data(:,1));
% sampling_rate = total_samples/elapsed_time;
% ecoimosc6002.info.sampling_rate = sampling_rate;
