% SAP_c6p02360114
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "c6p02360114".
%
% USAGE: c6p02360114 = SAP_acs030d(cfg)
%
% INPUT
%   cfg - corresponding row from the configuration table as a structure
%   array with scalar fields
%
% OUTPUT
%   c6p02360114 - structure with sensor information and data from specified file
%
% M. McFarland 2024-05-17
% Inspired by: N. Stockley

%% Declare function
function c6p02360114 = SAP_c6p02360114(cfg)

% Sensor information
c6p02360114.info.type = 'c6p'; % for level 2 processing
c6p02360114.info.sensor_id = 'c6p02360114';
c6p02360114.info.depth_rating_m = '500';
c6p02360114.info.timeoffset = cfg.timeoffset;
c6p02360114.info.depthoffset = cfg.depthoffset;
c6p02360114.info.calrow = cfg.calrow;
c6p02360114.info.mode = cfg.mode;

c6p02360114.info.ex_wvl = [460 365 590 525 635 525];
c6p02360114.info.em_wvl = [696 470 645 590 675 585];
c6p02360114.info.chlorophyll_excitation_nm = 460;
c6p02360114.info.chlorophyll_emission_nm = 696;
c6p02360114.info.cdom_excitation_nm = 365;
c6p02360114.info.cdom_emission_nm = 470;
c6p02360114.info.phycocyanin_standard_excitation_nm = 590;
c6p02360114.info.phycocyanin_standard_emission_nm = 645;
c6p02360114.info.phycoerythrin_standard_excitation_nm = 525;
c6p02360114.info.phycoerythrin_standard_emission_nm = 590;
c6p02360114.info.phycocyanin_custom_excitation_nm = 635;
c6p02360114.info.phycocyanin_custom_emission_nm = 675;
c6p02360114.info.phycoerythrin_custom_excitation_nm = 525;
c6p02360114.info.phycoerythrin_custom_emission_nm = 585;

%% Import data
% Imports data from extracted archive file.
pth = [cfg.path filesep cfg.fname];
fid = fopen(pth);
data = textscan(fid,'%n %s %s %n %n %n %n %n %n %n %n');
fclose(fid);
% data = cell2mat([data(:,1) data(:,4:9) data(:,11)]);
data = cell2mat([data(:,1) data(:,4:9)]);

c6p02360114.info.header = {'Time','ms';...
    'Chlorophyll-a','RFUB';'CDOM','RFUB';'Phycocyanin','RFUB';...
    'Phycoerythrin','RFUB';'PC-Custom','RFUB';'PE-Custom','RFUB'};
c6p02360114.raw = data;

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('c6p02360114_cal.mat') %#ok<*LOAD>
c6p02360114.info.cal.date = c6p02360114_cal{cfg.calrow,1}; 
c6p02360114.info.cal.header = c6p02360114_cal(1,1:11); 
c6p02360114.info.cal.values = c6p02360114_cal{cfg.calrow,2:11}; 

%% Calculate sampling rate (Hz)
% Calculates the data sampling rate by:
%
% $$sampling_-rate = \frac{total_-samples}{\frac{end_-time-start_-time}{1000}}$$
%
% The elapsed time must be divided by 1000 to convert from data time in
% milliseconds to seconds. The rate will be approximate when any data
% interruption occurs, resulting in elapsed time without samples.
% elapsed_time = (data(end,1) - data(1,1))/1000;
% total_samples = length(data(:,1));
% sampling_rate = total_samples/elapsed_time;
% c6p02360114.data.fluor.sampling_rate = sampling_rate;

% %% Fluoresence data array
% % Writes data and the information entered in LOG_ARRAY.ARCLOG into a
% % structure field for this sensor. Uses the calibration row value to write
% % data from the specified calibration. Also writes values previously
% % calculated in this function.
% c6p02360114.data.fluor.header = {'Time','ms';'[Depth]','m';...
%     'Chlorophyll-a','RFUB';'CDOM','RFUB';'Phycocyanin','RFUB';...
%     'Phycoerythrin','RFUB';'PC-Custom','RFUB';'PE-Custom','RFUB'};
% c6p02360114.data.fluor.mode = arclog_row{5};
% % c6p02360114.data.fluor.companion_archive = arclog_row{6};
% c6p02360114.data.fluor.reference_ctd = arclog_row{8};
% c6p02360114.data.fluor.calrow = arclog_row{10};
% c6p02360114.data.fluor.bin_mode = arclog_row{11};
% c6p02360114.data.fluor.timeoffset = arclog_row{12};
% c6p02360114.data.fluor.time_bins = arclog_row{13};
% c6p02360114.data.fluor.depthoffset = arclog_row{14};
% c6p02360114.data.fluor.depth_bins = arclog_row{15};
% c6p02360114.data.fluor.cal_date = c6p02360114_cal{str2double(arclog_row{10}),1}; %#ok<*IDISVAR,USENS>
% c6p02360114.data.fluor.cal_header = c6p02360114_cal(1,1:11); %#ok<*IDISVAR>
% c6p02360114.data.fluor.cal_values = c6p02360114_cal{str2double(arclog_row{10}),2:11}; %#ok<*IDISVAR,USENS>
% c6p02360114.data.fluor.sampling_rate = sampling_rate;
% c6p02360114.data.fluor.raw = data;

