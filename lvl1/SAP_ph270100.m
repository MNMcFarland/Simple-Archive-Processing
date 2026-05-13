% SAP_ph270100
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the
% sensor ID "ph270100"
%
% USAGE: ph270100 = SAP_ph270100(cfg)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT
%   ph270100 - struct array with data and sensor information
%
% M. McFarland 2024-05-20
% Inspired by: N. Stockley
%

function ph270100 = SAP_ph270100(cfg)

ph270100.info.sensor_id = 'ph270100';
ph270100.info.type = 'ph27'; % category for level 2 processing
ph270100.info.mode = cfg.mode;
ph270100.info.timeoffset = cfg.timeoffset;
ph270100.info.depthoffset = cfg.depthoffset;
ph270100.info.calrow = cfg.calrow;
ph270100.info.analognum = cfg.analognum;

%% Import data
pth = [cfg.path filesep cfg.fname];
data = importdata(pth);
idx = cfg.analognum;
data = [data(:,1) data(:,idx+2)];

%% Data array
% Writes pH voltage data and the information entered in LOG.ARCLOG into a
% structure field for this sensor. Uses the calibration row value to write
% data from the specified calibration.
ph270100.info.header = {'Time','ms'; 'Voltage','volts'};
ph270100.raw = data;

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('ph270100_cal.mat') %#ok<LOAD>
ph270100.info.cal.date = ph270100_cal{cfg.calrow,1}; %#ok<USENS>
ph270100.info.cal.ph_slope = ph270100_cal{cfg.calrow,2};
ph270100.info.cal.ph_offset = ph270100_cal{cfg.calrow,3};
ph270100.info.cal.orp_m = ph270100_cal{cfg.calrow,4};
ph270100.info.cal.orp_b = ph270100_cal{cfg.calrow,5};

% %% Calculate sampling rate (Hz)
% % Calculates the data sampling rate by:
% %
% % $$samplingrate = \frac{totalsamples}{\frac{endtime-starttime}{1000}}$$
% %
% % The elapsed time must be divided by 1000 to convert from data time in
% % milliseconds to seconds. The rate will be approximate when any data
% % interruption occurs, resulting in elapsed time without sensor_infosamples.
% elapsed_time = (data(end,1) - data(1,1))/1000;
% total_samples = size(data,1);
% sampling_rate = total_samples/elapsed_time;
% ph270100.info.sampling_rate = sampling_rate;


