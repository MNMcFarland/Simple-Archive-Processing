% SAP_ctd49002
%
% Reads sensor information and data from
% WAP-extracted files identified in cfg as having the sensor
% ID "ctd49002". Called by SAP_lvl_1.
%
% USAGE: ctd490013 = SAP_ctd49002(cfg_row)
%
% INPUT
%   cfg - a single row of configuration table as a structure array with
%   scalar fields
%
% OUTPUT:
%   ctd49002 - structure with sensor data and info
%
% M. McFarland 2024-05-20
% Inspired by N. Stockley
%

function ctd49002 = SAP_ctd49002(cfg)

% sensor info
ctd49002.info.sensor_id = 'ctd49002';
ctd49002.info.mode = cfg.mode;
ctd49002.info.timeoffset = cfg.timeoffset;
ctd49002.info.depthoffset = cfg.depthoffset;
ctd49002.info.type = 'ctd'; % category for level 2 processing
calrow = cfg.calrow;
ctd49002.info.calrow = calrow;

%% Load calibration data
% Loads the sensor calibration data into the function workspace.
load('ctd49002_cal.mat')
ctd49002.info.cal.date = ctd49002_cal{calrow,1};
ctd49002.info.cal.T_a0 = ctd49002_cal{calrow,2};
ctd49002.info.cal.T_a1 = ctd49002_cal{calrow,3};
ctd49002.info.cal.T_a2 = ctd49002_cal{calrow,4};
ctd49002.info.cal.T_a3 = ctd49002_cal{calrow,5};
ctd49002.info.cal.C_g = ctd49002_cal{calrow,6};
ctd49002.info.cal.C_h = ctd49002_cal{calrow,7};
ctd49002.info.cal.C_i = ctd49002_cal{calrow,8};
ctd49002.info.cal.C_j = ctd49002_cal{calrow,9};
ctd49002.info.cal.C_Pcor = ctd49002_cal{calrow,10};
ctd49002.info.cal.C_Tcor = ctd49002_cal{calrow,11};
ctd49002.info.cal.P_A0 = ctd49002_cal{calrow,12};
ctd49002.info.cal.P_A1 = ctd49002_cal{calrow,13};
ctd49002.info.cal.P_A2 = ctd49002_cal{calrow,14};
ctd49002.info.cal.P_TempA0 = ctd49002_cal{calrow,15};
ctd49002.info.cal.P_TempA1 = ctd49002_cal{calrow,16};
ctd49002.info.cal.P_TempA2 = ctd49002_cal{calrow,17};
ctd49002.info.cal.P_TCA0 = ctd49002_cal{calrow,18};
ctd49002.info.cal.P_TCA1 = ctd49002_cal{calrow,19};
ctd49002.info.cal.P_TCA2 = ctd49002_cal{calrow,20};
ctd49002.info.cal.P_TCB0 = ctd49002_cal{calrow,21};
ctd49002.info.cal.P_TCB1 = ctd49002_cal{calrow,22};
ctd49002.info.cal.P_TCB2 = ctd49002_cal{calrow,23};

%% Initialize mode loop
sensor_mode = cfg.mode;
pth = [cfg.path filesep cfg.fname];
switch sensor_mode
    case 'ascii'
        %% Import ASCII data
        % Imports ascii-formated data in engineering units (OutputFormat =
        % 3) from extracted archive file. Rearranges data in the correct
        % order: time, depth, temperature, conductivity, salinity.
        fid = fopen(pth);
        %data = textscan(fid,'%n %n %n %n %n','Delimiter',{'\t',',','"',' '},'MultipleDelimsAsOne',1);
        real_data_length = size(importdata(pth),1);
        fclose(fid);
        current_data_length = 0;
        good_data = {};
        while current_data_length < real_data_length
            fid = fopen(pth);
            data = textscan(fid,'%n %n %n %n %n','Delimiter',{'\t',',','"',' '},'MultipleDelimsAsOne',1,'HeaderLines',current_data_length);
            fclose(fid);
            if isempty(data{1,5})
                current_data_length = current_data_length + 1;
            elseif size(data{1,5},1) == real_data_length
                good_data = vertcat(good_data,data);
                break
            elseif current_data_length + size(data{1,5},1) == real_data_length
                good_data = vertcat(good_data,data);
                current_data_length = current_data_length + size(data{1,5},1);
                break
            else
                if size(data{1,1},1) == size(data{1,5},1)
                    for x = 1:5
                        data{1,x}(end) = [];
                    end
                elseif size(data{1,1},1) > size(data{1,5},1)
                    for x = 1:4
                        if size(data{1,x},1) > size(data{1,5},1)
                            data{1,x}(end) = [];
                        end
                    end
                end
                if isempty(data{1,5})
                    current_data_length = current_data_length + 1;
                elseif any(any([isnan(data{1,1}),isnan(data{1,2}),isnan(data{1,3}),isnan(data{1,4}),isnan(data{1,5})]))
                    row_count = 0;
                    for x = 1:5
                        if any(isnan(data{1,x}))
                            where_nan = find(isnan(data{1,x}));
                            row_count = row_count + length(where_nan);
                            for y = 1:length(where_nan)
                                for z = 1:5
                                    if where_nan(y) == 1
                                        data{1,z}(where_nan(y)) = [];
                                    else
                                        data{1,z}(where_nan(y)-1:where_nan(y)) = [];
                                    end
                                end
                            end
                        end
                    end
                    if isempty(data{1,5})
                        current_data_length = current_data_length + row_count + 1;
                    else
                        good_data = vertcat(good_data,data);
                        current_data_length = current_data_length + size(data{1,1},1) + row_count + 1;
                    end
                else
                    good_data = vertcat(good_data,data);
                    current_data_length = current_data_length + size(data{1,1},1) + 1;
                end
            end
        end
        data = cell2mat([good_data(:,1) good_data(:,4) good_data(:,2:3) good_data(:,5)]);
        
    case 'hex'
        %% Import Hex data
        % Imports raw hexidecimal data (OutputFormat = 0) from extracted
        % archive file and converts to decimal numbers.
        fid = fopen(pth);
        hex_data = textscan(fid,'%n %s');
        fclose(fid);
        time = zeros(size(hex_data{1,1},1),1);
        t = zeros(size(hex_data{1,1},1),1);
        c = zeros(size(hex_data{1,1},1),1);
        p = zeros(size(hex_data{1,1},1),1);
        v = zeros(size(hex_data{1,1},1),1);
        for x = 1:size(hex_data{1,1},1)
            if length(hex_data{1,2}{x}) == 22
                time(x) = hex_data{1,1}(x);
                t(x) = hex2dec(hex_data{1,2}{x}(1:6)); % Temperature, counts
                c(x) = hex2dec(hex_data{1,2}{x}(7:12))/265; % Conductivity, Hz
                p(x) = hex2dec(hex_data{1,2}{x}(13:18)); % Pressure, counts
                v(x) = hex2dec(hex_data{1,2}{x}(19:22))/13107; % Pressure temperature compensation, volts
            else
                time(x) = NaN;
                t(x) = NaN;
                c(x) = NaN;
                p(x) = NaN;
                v(x) = NaN;
            end
        end
               
        %% Apply temperature calibration
        T_a0 = ctd49002_cal{calrow,2}; %#ok<*IDISVAR,*USENS>
        T_a1 = ctd49002_cal{calrow,3};
        T_a2 = ctd49002_cal{calrow,4};
        T_a3 = ctd49002_cal{calrow,5};
        
        MV = (t - 524288) / 1.6e7;
        R = (MV * 2.295e10 + 9.216e8) ./ (6.144e4 - MV * 5.3e5);
        Temp = 1./(T_a0 + T_a1*log(R) + T_a2*log(R).^2 + T_a3*log(R).^3) - 273.15; % deg C, ITS-90
        
        %% Apply pressure calibration
        P_A0 = ctd49002_cal{calrow,12};
        P_A1 = ctd49002_cal{calrow,13};
        P_A2 = ctd49002_cal{calrow,14};
        P_TempA0 = ctd49002_cal{calrow,15};
        P_TempA1 = ctd49002_cal{calrow,16};
        P_TempA2 = ctd49002_cal{calrow,17};
        P_TCA0 = ctd49002_cal{calrow,18};
        P_TCA1 = ctd49002_cal{calrow,19};
        P_TCA2 = ctd49002_cal{calrow,20};
        P_TCB0 = ctd49002_cal{calrow,21};
        P_TCB1 = ctd49002_cal{calrow,22};
        P_TCB2 = ctd49002_cal{calrow,23};

        y = Temp;
        z = P_TempA0 + P_TempA1 * y + P_TempA2 * y.^2;
        x = p - P_TCA0 - P_TCA1 .* z - P_TCA2 .* z.^2;
        n = x * P_TCB0 ./ (P_TCB0 + P_TCB1 .* z + P_TCB2 .* x.^2);
        Press = P_A0 + P_A1 * n + P_A2 * n.^2; % psia
        Press = (Press - 14.7) * 0.689476; % decibars      
        
        %% Apply conductivity calibration
        C_g = ctd49002_cal{calrow,6};
        C_h = ctd49002_cal{calrow,7};
        C_i = ctd49002_cal{calrow,8};
        C_j = ctd49002_cal{calrow,9};
        C_Pcor = ctd49002_cal{calrow,10};
        C_Tcor = ctd49002_cal{calrow,11};
        
        f = c / 1000;
        Cond = (C_g + C_h*f.^2 + C_i*f.^3 + C_j*f.^4) ./ (1 + C_Tcor * Temp + C_Pcor * Press ); % Siemens/meter 
        
        %% Calculate salinity
        A1 = 2.070e-5;
        A2 = -6.370e-10;
        A3 = 3.989e-15;
        B1 = 3.426e-2;
        B2 = 4.464e-4;
        B3 = 4.215e-1;
        B4 = -3.107e-3;
        C0 = 6.766097e-1;
        C1 = 2.00564e-2;
        C2 = 1.104259e-4;
        C3 = -6.9698e-7;
        C4 = 1.0031e-9;
        a=[0.0080, -0.1692, 25.3851, 14.0941, -7.0261, 2.7081];
        b=[0.0005, -0.0056, -0.0066, -0.0375, 0.0636, -0.0144];
        C = Cond; % S/m
        T = Temp * 1.00024; % deg C, IPTS-68
        P = Press; % decibars

        neg_C = C <= 0;
        C(neg_C) = NaN;
        C = C*10.0; % convert Siemens/meter to mmhos/cm
        R = C ./ 42.914;
        val = 1 + B1 .* T + B2 .* T.^2 + B3 .* R + B4 .* R .* T;
        RP = 1 + (P .* (A1 + P .* (A2 + P .* A3))) ./ val;
        val = RP .* (C0 + (T .* (C1 + T .* (C2 + T .* (C3 + T .* C4)))));
        RT = R ./ val;
        neg_RT = RT <= 0;
        RT(neg_RT) = 0.000001;
        sum1 = zeros(size(C));
        sum2 = zeros(size(C));
        for n=0:5
            temp = RT.^(n/2);
            sum1 = sum1 + a(n+1) * temp;
            sum2 = sum2 + b(n+1) * temp;
        end
        val = 1.0 + 0.0162 * (T - 15.0);
        PSU = sum1 + sum2 .* (T - 15.0) ./ val;
        
        data = [time Press Temp Cond PSU];
        
end % End mode loop

%% Sigma T calculation
% Calculates density using the measured temperature and salinity values.
%
% Source: Woods Hole Oceanographic Institution, U.S. GLOBEC. MATLAB Code Used
% to Derive Sigma T. http://globec.whoi.edu/globec-dir/sigmat-calc-matlab.html
% (accessed Jun 7, 2006).
ctd49002.info.documentation(4,1) = {'Sigma T:'};
ctd49002.info.documentation{4,4} = horzcat('Woods Hole ',...
    'Oceanographic Institution, U.S. GLOBEC. MATLAB Code Used to Derive ',...
    'Sigma T. http://globec.whoi.edu/globec-dir/sigmat-calc-matlab.html ',...
    '(accessed Jun 7, 2006).');
a = [6.536332e-9 -1.120083e-6 1.001685e-4 -9.095290e-3 6.793952e-2 999.842594];
b = [5.3875e-9 -8.2467e-7 7.6438e-5 -4.0899e-3 8.24493e-1];
c = [-1.6546e-6 1.0227e-4 -5.72466e-3];
d = 4.8314e-4;
t = data(:,3);
s = data(:,5);
sig = polyval(a,t) + (polyval(b,t) + polyval(c,t).*sqrt(s)+d*s).*s - 1000;
data(:,6) = sig;

%% Data array
% Writes data and the information entered in LOG_ARRAY.ARCLOG into a
% structure field for this sensor. Also writes values previously calculated
% in this function.
ctd49002.info.header = {'Time','ms';'Depth','db';...
    'Temp','C';'Conductivity','S/m';'Salinity','PSU';'Sigma t','kg/m^3'};
ctd49002.raw = data;

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
% ctd49002.info.sampling_rate = sampling_rate;

