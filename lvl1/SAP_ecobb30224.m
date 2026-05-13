% SAP_ecobb30224
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "ecobb30224"
%
% USAGE: ecobb30224 = SAP_ecobb30224(cfg)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT
%   acobb30221 - structure with sensor data and info
%
% M. McFarland 2024-05-17
% Inspired by: N. Stockley
%

function ecobb30224 = SAP_ecobb30224(cfg)

%% Sensor information
% Writes information about the sensor to the structure field. This
% information will be called in later processing.
ecobb30224.info.type = 'ecobb3'; % for level 2 processing
ecobb30224.info.sensor_id = 'ecobb30224';
ecobb30224.info.depth_rating_m = '500';
ecobb30224.info.centroid_theta_deg = [124 124 124];
ecobb30224.info.centroid_lambda_nm = [470 532 660];
ecobb30224.info.pathlength_m = [0.015 0.015 0.015];
ecobb30224.info.chi_factor = [1.076 1.076 1.076];
ecobb30224.info.sat_val = 3900;
ecobb30224.info.timeoffset = cfg.timeoffset;
ecobb30224.info.depthoffset = cfg.depthoffset;
ecobb30224.info.calrow = cfg.calrow;
ecobb30224.info.mode = cfg.mode;

%% Import data
% Imports data from extracted archive file.
pth = [cfg.path filesep cfg.fname];
fid = fopen(pth);
data = textscan(fid,'%n %s %s %n %n %n %n %n %n %n');
fclose(fid);
data = cell2mat([data(:,1) data(:,4:end)]);

%% Scattering data array
% Writes data and the information entered in LOG_ARRAY.ARCLOG into a
% structure field for this sensor. Uses the calibration row value to write
% data from the specified calibration. Also writes values previously
% calculated in this function.
ecobb30224.info.header = {'Time','ms';...
    'beta470','counts';'beta532','counts';'beta660','counts'};
ecobb30224.raw = [data(:,1) data(:,3:2:7)];

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('ecobb30224_cal.mat','ecobb30224_cal');
ecobb30224.info.cal.date = ecobb30224_cal{cfg.calrow,1}; 
ecobb30224.info.cal.scaling_factor = ecobb30224_cal{cfg.calrow,5};
ecobb30224.info.cal.dark_offset = ecobb30224_cal{cfg.calrow,6};

%% Internal temperature reference
% Writes time and internal temperature reference data and the information
% entered in LOG_ARRAY.ARCLOG for the data into a structure field for this
% sensor. This allows the internal temperature reference data to be
% processed similarly to the data so that any issues can be located
% relative to the data. Also writes values previously calculated in this
% function.
ecobb30224.info.itemp.header = {'Time','ms';...
    'Internal temperature reference',''};
ecobb30224.info.itemp.raw = [data(:,1) data(:,8)];

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
% ecobb30224.info.sampling_rate = sampling_rate;

%% Check for saturation


