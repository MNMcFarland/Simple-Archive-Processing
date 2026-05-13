%% SAP_ecfl30143
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "ecofl30143"
%
% USAGE: ecofl30143 = SAP_ecofl30143(cfg)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT
%   ecofl30143 - struct array with data and sensor information
%
% M. McFarland 2024-05-20
% Inspired by: N. Stockley
%

function ecofl30143 = SAP_ecofl30143(cfg)


%% Sensor information
% Writes information about the sensor to the structure field. This
% information will be called in later processing.
ecofl30143.info.type = 'ecofl3'; % for level 2 processing
ecofl30143.info.sensor_id = 'ecofl30143';
ecofl30143.info.depth_rating_m = '500';
ecofl30143.info.chl_1_excitation_nm = 440;
ecofl30143.info.chl_1_emission_nm = 680;
ecofl30143.info.chl_2_excitation_nm = 510;
ecofl30143.info.chl_2_emission_nm = 680;
ecofl30143.info.cdom_excitation_nm = 370;
ecofl30143.info.cdom_emission_nm = 470;
ecofl30143.info.timeoffset = cfg.timeoffset;
ecofl30143.info.depthoffset = cfg.depthoffset;
ecofl30143.info.calrow = cfg.calrow;
ecofl30143.info.mode = cfg.mode;

%% Import data
% Imports data from extracted archive file.
pth = [cfg.path filesep cfg.fname];
fid = fopen(pth);
data = textscan(fid,'%n %s %s %n %n %n %n %n %n %n');
fclose(fid);
data = cell2mat([data(:,1) data(:,4:end)]);

%% Fluoresence data array
% Writes data and the information entered in LOG_ARRAY.ARCLOG into a
% structure field for this sensor. Uses the calibration row value to write
% data from the specified calibration. Also writes values previously
% calculated in this function.
ecofl30143.info.header = {'Time','ms';...
    'Chl_1','counts';'Chl_2','counts';'CDOM','counts'};
% ecofl30143.data.fluor.header_corr = {'Time','ms';'[Depth]','m';...
    % 'Chlorophyll-1','counts';'Chlorophyll-2','counts';'CDOM','counts'};
% ecofl30143.data.fluor.mode = cfg_row{5};
% ecofl30143.data.fluor.companion_archive = cfg_row{6};
% ecofl30143.data.fluor.reference_ctd = cfg_row{8};
% ecofl30143.data.fluor.calrow = cfg_row{10};
% ecofl30143.data.fluor.bin_mode = cfg_row{11};
% ecofl30143.data.fluor.timeoffset = cfg_row{12};
% ecofl30143.data.fluor.time_bins = cfg_row{13};
% ecofl30143.data.fluor.depthoffset = cfg_row{14};
% ecofl30143.data.fluor.depth_bins = cfg_row{15};
ecofl30143.raw = [data(:,1) data(:,3:2:7)];

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('ecofl30143_cal.mat') %#ok<*LOAD>
ecofl30143.info.cal_date = ecofl30143_cal{cfg.calrow,1}; %#ok<*IDISVAR,USENS>
ecofl30143.info.cal.scaling_factor = ecofl30143_cal{cfg.calrow,2};
ecofl30143.info.cal.dark_offset = ecofl30143_cal{cfg.calrow,3};

%% Check for saturation
% Finds all data values that exceed specified saturation value. If such
% values are found, a record is created in the flag structure field that
% alerts of this excursion. The uncorrected data is reassigned for
% reference and the excessive data values are defined as the saturation
% value for further processing.
ecofl30143.info.sat_val = 3900;
% data_vals = data(:,3:2:7);
% where_sat = data_vals > sat_val;
% if any(any(where_sat))
%     arc_array.flag.ecofl30143.saturation.description = {'Signal saturation occured'};
%     arc_array.flag.ecofl30143.saturation.where_sat = [data(:,1) where_sat];
%     saturated_data = data;
%     ecofl30143.data.fluor.saturated = saturated_data;
%     data_vals(where_sat) = NaN;
%     data(:,5:2:9) = data_vals;
% end

%% Internal temperature reference
% Writes time and internal temperature reference data and the information
% entered in LOG_ARRAY.ARCLOG for the data into a structure field for this
% sensor. This allows the internal temperature reference data to be
% processed similarly to the data so that any issues can be located
% relative to the data. Also writes values previously calculated in this
% function.
ecofl30143.info.itemp.header = {'Time','ms';...
    'Internal temperature reference',''};
% ecofl30143.data.itemp_ref.reference_ctd = cfg__row{8};
% ecofl30143.data.itemp_ref.bin_mode = cfg__row{11};
% ecofl30143.data.itemp_ref.timeoffset = cfg__row{12};
% ecofl30143.data.itemp_ref.time_bins = cfg__row{13};
% ecofl30143.data.itemp_ref.depthoffset = cfg__row{14};
% ecofl30143.data.itemp_ref.depth_bins = cfg__row{15};
% ecofl30143.data.itemp_ref.sampling_rate = sampling_rate;
ecofl30143.info.itemp.raw = [data(:,1) data(:,8)];

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
% ecofl30143.info.sampling_rate = sampling_rate;

% %% Dark log
% % If the mode in LOG_ARRAY.ARCLOG is specified as "dark", calculates the
% % median of the data and assigns to a sensor-specific field within
% % LOG_ARRAY.DARKS.
% if strcmp(cfg__row{5},'dark')
%     [log_array] = evalin('caller','log_array');
%     dark_fluor_data = data(:,3:2:7);
%     if isfield(log_array,'darks')
%         if isfield(log_array.darks,'ecofl30143')
%             is_arc = find(log_array.darks.ecofl30143.fluor(:,1) == str2double(cfg__row{1}));
%             if isempty(is_arc)
%                 len = size(log_array.darks.ecofl30143.fluor,1);
%                 log_array.darks.ecofl30143.fluor(len+1,1) = str2double(cfg__row{1});
%                 log_array.darks.ecofl30143.fluor(len+1,2:4) = median(dark_fluor_data);
%             elseif ~isempty(is_arc)
%                 log_array.darks.ecofl30143.fluor(is_arc,2:4) = median(dark_fluor_data);
%             end
%         elseif ~isfield(log_array.darks,'ecofl30143')
%             log_array.darks.ecofl30143.fluor(1,1) = str2double(cfg__row{1});
%             log_array.darks.ecofl30143.fluor(1,2:4) = median(dark_fluor_data);
%         end
%     elseif ~isfield(log_array,'darks')
%         log_array.darks.ecofl30143.fluor(1,1) = str2double(cfg__row{1});
%         log_array.darks.ecofl30143.fluor(1,2:4) = median(dark_fluor_data);
%     end
%     assignin('caller','log_array',log_array)
% end
% 
% end % End function