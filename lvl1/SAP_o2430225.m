% SAP_o2430225
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the
% sensor ID "o2430225"
%
% USAGE: o2430225 = SAP_o2430225(cfg)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT
%   o2430035 - struct array with data and sensor information
%
% M. McFarland 2024-05-20
% Created by: N. Stockley
%

function o2430225 = SAP_o2430225(cfg)

o2430225.info.sensor_id = 'o2430225';
o2430225.info.type = 'o243'; % category for level 2 processing
o2430225.info.mode = cfg.mode;
o2430225.info.timeoffset = cfg.timeoffset;
o2430225.info.depthoffset = cfg.depthoffset;
o2430225.info.calrow = cfg.calrow;
o2430225.info.analognum = cfg.analognum;

%% Import data
pth = [cfg.path filesep cfg.fname];
data = importdata(pth);
idx = cfg.analognum;
data = [data(:,1) data(:,idx+2)];

%% Data array
% Writes O2 voltage data and the information entered in LOG.ARCLOG into a
% structure field for this sensor. Uses the calibration row value to write
% data from the specified calibration.
o2430225.info.header = {'Time','ms';...
    'Voltage','volts'};
o2430225.raw = data;

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('o2430225_cal.mat') %#ok<*LOAD>
o2430225.info.cal.date = o2430225_cal{cfg.calrow,1}; %#ok<*IDISVAR,USENS>
o2430225.info.cal.soc = o2430225_cal{cfg.calrow,2};
o2430225.info.cal.v_offset = o2430225_cal{cfg.calrow,3};
o2430225.info.cal.tau20 = o2430225_cal{cfg.calrow,4};
o2430225.info.cal.A = o2430225_cal{cfg.calrow,5};
o2430225.info.cal.B = o2430225_cal{cfg.calrow,6};
o2430225.info.cal.C = o2430225_cal{cfg.calrow,7};
o2430225.info.cal.E = o2430225_cal{cfg.calrow,8};
o2430225.info.cal.D1 = o2430225_cal{cfg.calrow,9};
o2430225.info.cal.D2 = o2430225_cal{cfg.calrow,10};
o2430225.info.cal.H1 = o2430225_cal{cfg.calrow,11};
o2430225.info.cal.H2 = o2430225_cal{cfg.calrow,12};
o2430225.info.cal.H3 = o2430225_cal{cfg.calrow,13};

% %% Calculate sampling rate (Hz)data.ph.
% % Calculates the data sampling rate by:
% %
% % $$samplingrate = \frac{totalsamples}{\frac{endtime-starttime}{1000}}$$
% %
% % The elapsed time must be divided by 1000 to convert from data time in
% % milliseconds to seconds. The rate will be approximate when any data
% % interruption occurs, resulting in elapsed time without samples.
% elapsed_time = (data(end,1) - data(1,1))/1000;
% total_samples = size(data,1);
% sampling_rate = total_samples/elapsed_time;
% o2430035.info.sampling_rate = sampling_rate;
 



