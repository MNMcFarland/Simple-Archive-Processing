% getscat_L200X reads in and corrects scattering data from a LISST-200X RBN file
% 
% Usage:
%   RBNdata = getscat_L200X(datafile)  
%   OR
%   RBNdata = getscat_L200X(datafile,backgroundFile)
%
% Inputs:
%   getscat_L200X accepts a string with the location of a 200X .RBN data
%   file. Calibration information and background measurements are
%   contained in the .RBN file, therefore no other information is required.
%   Optionally, a background file (.BGT) different from the one contained 
%   in the .RBN file can be specified as the second argument. The data in 
%   the .RBN will then be processed using the supplied background file.
%
% Output:
%   getscat_L200X outputs a structure containing the following data.
%       cscat:           Corrected scattering
%       date:            Timestamp in Matlab datenum
%       transmission:    Optical transmission
%       depth:           Depth in meters
%       temperature:     Temperature in degrees Celsius
%       estMeanDiameter: Estimated Sauter mean diameter (um)
%       estTotalConc:    Estimated total concentration (uL/L)
%       Lp:              Transmitted laser power (mW)
%       Lref:            Laser power reference (mW)
%       analog1:         Analog input 1
%       analog2:         Analog input 2
%       analog3:         Analog input 3
%       supplyVolts:     Supply voltage (V)
%       humidity:        Internal instrument relative humidity (%)
%       accelXYZ:        Accelerometer X, Y, and Z
%       raw:             Raw data as it appears in the RBN file
%       factory_bkgrd:   The factory background (corrections applied to aux data)
%       bkgrd:           User collected background (corrections applied to aux data)
%       ambientLight:    Counts of ambient light removed from rings values
%       config:          Structure containing various instrument information
%       dcal:            Ring area coefficients
%       Ta:              Vector to convert corrected scattering to estimated total area concentration
%       Tv:              Vector to convert corrected scattering to estimated total volume concentration
%       angles:          Ring detector center angles (degrees)
%       VSF:             Volume scattering function for ring detector angles (magnitude not calibrated)
%
% Sequoia Scientific, Inc. - 12/01/2020



function RBNdata = getscat_L200X_ZPWEdit(rawData,bkgrd,factoryBkgrd,dcal,VCC)

%**************************************************************************
%1: Read the binary data file, check for user supplied background file
%**************************************************************************


% ALREADY BINARY FROM DH4!!
% [zsc,fzs,dcal,rawData,Tv,Ta,config,housek] = parse200XBinary(varargin{1});

% if supplied, load an external background file
% if length(varargin) == 2
%     zsc = load(varargin{2},'-ascii')';
%     zsc(1:36) = zsc(1:36) .* 10;
%     
%     disp('Using clean water bkgd provided in argument 2!!!')
%     
% elseif length(varargin) > 2
%     error('Error: getscat_L200X only accepts up to two input arguments');
% end

% check for the necessary information
% if (isempty(zsc) || isempty(fzs) || isempty(dcal) || isempty(rawData))
%     error(['Error: Data file contains no data or is missing critical ' ...
%         'information such as the background or factory background']);
% end

data = rawData;
fzs  = factoryBkgrd;
zsc  = bkgrd;
config.VCC = VCC;
dcal = dcal;

% Divide rings 1-36 by 10 to match L100 convention
data(:,1:36) = data(:,1:36)./10;       
fzs(1:36) = fzs(1:36)./10;
zsc(1:36) = zsc(1:36)./10;

%**************************************************************************
%2: Compute optical transmission, raw scattering, corrected scatting and VSF
%**************************************************************************

rows = size(data,1);

LaserRatio = zsc(37)/zsc(40);   % ratio of transmitted power / laser ref
tau = data(:,37)./LaserRatio./data(:,40); % compute optical transmission, taking the eventual drift in laser power into account

scat = data(:,1:36)./repmat(tau,1,36);                                     % correct for attenuation
scat = scat - repmat(zsc(1:36),rows,1) .* repmat(data(:,40)./zsc(40),1,36);% subtract the background
cscat = scat .* repmat(dcal,rows,1);                                       % apply ring area file

% [RBNdata.angles, RBNdata.VSF] = getVSF_L200X(cscat,config,data(:,40));   % calculate uncalibrated VSF
cscat = cscat .* repmat(fzs(40)./data(:,40),1,36);                         % normilize to factory LREF
cscat = cscat ./ config.VCC;                                               % apply concentration calibration

cscat(cscat<0) = 0; % negative cscats are not possible, so set them to 0.

%**************************************************************************
%3: Apply corrections to auxiliary data
%**************************************************************************

% if ~isempty(housek)
% % create scale and offset correction arrays
% scale = ones(1,23);
% scale(1) = housek(17);   % Laser Transmission
% scale(2) = 0.01;         % Supply Voltage
% scale(3) = 0.0001;       % Analog Input 1
% scale(4) = housek(16);   % Laser Reference
% scale(5) = housek(3);    % Depth
% scale(6) = housek(12);   % Temperature
% scale(13) = 0.0001;      % Analog Input 2
% scale(14) = housek(15);  % Sauter Mean Diameter
% scale(15) = housek(14);  % Total Volume Concentration
% scale(23) = 0.0001;      % Analog Input 3
% 
% offset = zeros(1,23);
% offset(5) = housek(4);   % Depth
% offset(6) = housek(13);  % Temperature
% 
% % apply corrections
% data(:,37:59) = data(:,37:59) .* repmat(scale,rows,1) + repmat(offset,rows,1);
% scale(15) = 0.01; % total concentration replaced by path length (x100) in background records 
% zsc(1,37:59) = zsc(1,37:59) .* scale + offset;
% fzs(1,37:59) = fzs(1,37:59) .* scale + offset;
% else
%     warning(['auxiliary correction factors were not found in the ' ...
%         'RBN file, auxiliary parameters will remain uncorrected.']);
% end

%**************************************************************************
%4: Save the data in a structure
%**************************************************************************

RBNdata.cscat = cscat;
RBNdata.date = datetime(data(:,43:48));
RBNdata.transmission = tau;
RBNdata.depth = data(:,41);
RBNdata.temperature = data(:,42);
RBNdata.estMeanDiameter = data(:,50);
RBNdata.estTotalConc = data(:,51);
RBNdata.Lp = data(:,37);
RBNdata.Lref = data(:,40);
RBNdata.analog1 = data(:,39);
RBNdata.analog2 = data(:,49);
RBNdata.analog3 = data(:,59);
RBNdata.supplyVolts = data(:,38);
RBNdata.humidity = data(:,52);
RBNdata.accelXYZ = data(:,53:55);
RBNdata.raw = rawData;
% RBNdata.factory_bkgrd = bkgrd;
RBNdata.bkgrd = bkgrd;
RBNdata.ambientLight = data(:,58);
% RBNdata.config = config;
RBNdata.dcal = dcal;
% RBNdata.Ta = Ta;
% RBNdata.Tv = Tv;
end

function [angles,vsf] = getVSF_L200X(cscat,config,Lref)

[rows,~] = size(cscat);

% calculate angles in water in radians (120mm focal length)
rho = 1.18;
theta0air = (0.102/120);
edge_angles = theta0air*rho.^(0:36);
edge_angles = asin(sin(edge_angles)/1.33); % convert air angles to in water angles

% find solid angle
dOmega=cos(edge_angles(1:36))-cos(edge_angles(2:37));  
dOmega=dOmega*2*pi/6; % factor 6 takes care of rings covering only 1/6th circle

% calculate detector center angles in degrees
angles = (180./pi) .* (sqrt(edge_angles(1:36).*edge_angles(2:37)));

% compute light on rings
Watt_per_count_on_rings = 1.9e-10; % assumed the same for all detectors
light_on_rings = cscat.*Watt_per_count_on_rings;

% calculate incident laser power from LREF
Watt_per_count_laser_ref = 1;                 % THIS IS UNKNOWN! 
laser_incident_power = Lref*Watt_per_count_laser_ref; 

% compute VSF (no calibration for Lref, so magnitude is not correct)
vsf = light_on_rings ./ repmat(dOmega,rows,1) ./ repmat(laser_incident_power,1,36) ./ (config.effPath/1000);
end

function [zsc,fzs,dcal,data,Tv,Ta,config,housek] = parse200XBinary(datafile)

% record IDs
DCAL_RECORD_ID = 44778;
TV1_RECORD_ID = 49391;    
TV2_RECORD_ID = 49394;    
TA1_RECORD_ID = 44047;    
TA2_RECORD_ID = 44274;    
ZSCAT_RECORD_ID = 47820;
FZSCAT_RECORD_ID = 64428;
CONFIG_RECORD_ID = 19529;
HOUSEK_RECORD_ID = 52928;
DATA_RECORD_ID = 56026;

fid = fopen(datafile,'r','b'); % open file for reading using big endian format
fseek(fid, 0, 'eof');
fileSize = ftell(fid); % get the file size
fseek(fid, 0, 'bof');
recordID = fread(fid,1,'uint16'); % read the first record ID

% calculate number of records in the file
RecordSize = 120; % 120 bytes per record
numRecords = fileSize/RecordSize; 

% Number of data records should be an integer
if floor(numRecords) ~= numRecords
   warning('File contains incomplete data records');
   numRecords = floor(numRecords);
end

% calculate the number of variables in each record
num16 = (RecordSize/2)-1;
num32 = floor((RecordSize-2)/4);

[zsc,fzs,dcal,Tv,Ta,config,housek] = deal([]);
data = NaN(numRecords,num16); % preallocate data array for big speed increase

% loop through the file and read in the data according to the record ID
for recordNumber = 1:numRecords
    switch recordID
        case ZSCAT_RECORD_ID
            zsc = fread(fid,num16,'uint16')';
        case DATA_RECORD_ID
            data(recordNumber,:) = fread(fid,num16,'uint16')';
        case DCAL_RECORD_ID
            dcal = fread(fid,num16,'uint16')';
            dcal = dcal(2:37)./dcal(1);
        case FZSCAT_RECORD_ID
            fzs = fread(fid,num16,'uint16')';
        case CONFIG_RECORD_ID
            fseek(fid,-2,'cof');
            config.name = fread(fid,20,'*char')';
            config.serialNumber = fread(fid,1,'uint16');
            config.firmwareVer = fread(fid,1,'uint16').*0.001;
            config.VCC = fread(fid,1,'uint32');
            config.fullPath = fread(fid,1,'uint16').*0.01;
            config.effPath = fread(fid,1,'uint16').*0.01;
            config.bioBlock = fread(fid,1,'uint8');
            config.sTube = fread(fid,1,'uint8');
            config.analogConcScale = fread(fid,1,'uint16');
            config.endcap = fread(fid,1,'uint16');
            config.startCond = fread(fid,1,'uint16');
            config.startCondData = fread(fid,20,'*char')';
            config.stopCond = fread(fid,1,'uint16');
            config.stopCondData = fread(fid,20,'*char')';
            config.measurementAve = fread(fid,1,'uint16');
            config.sampleInterval = fread(fid,1,'uint16');
            config.sampleMode = fread(fid,1,'uint16');
            config.burstSamples = fread(fid,1,'uint16');
            config.burstInterval = fread(fid,1,'uint16');
            config.transmitRaw = fread(fid,1,'uint16');
            config.lifetimeSamples = fread(fid,1,'uint32');
            config.lifetimeLaserOn = fread(fid,1,'uint32');
            config.supportBoard = fread(fid,1,'uint16');
            config.ambientLight = fread(fid,1,'uint16');
        case HOUSEK_RECORD_ID
            housek=fread(fid,num32,'float')';
        case TV1_RECORD_ID
            Tv(1:num32)=fread(fid,num32,'float')';
        case TV2_RECORD_ID
            Tv(30:36)=fread(fid,7,'float')';
        case TA1_RECORD_ID
            Ta(1:num32)=fread(fid,num32,'float')';
        case TA2_RECORD_ID
            Ta(30:36)=fread(fid,7,'float')';
        otherwise
            warning('Unrecognized data record ID found in .RBN file') 
    end
    fseek(fid,recordNumber * RecordSize,'bof'); % go the location of the next record ID
    recordID = fread(fid,1,'uint16');        % read the next record ID
end
fclose(fid);

% remove NaN rows from data matrix that correspond to header data rows
data(all(isnan(data),2),:) = [];

% negative ring values are possible, data must be corrected
data(data(:,1:36)>40950) = data(data(:,1:36)>40950) - 65536;
fzs(fzs(:,1:36)>40950) = fzs(fzs(:,1:36)>40950) - 65536;
zsc(zsc(:,1:36)>40950) = zsc(zsc(:,1:36)>40950) - 65536;
end

% LOG
% 04/11/14 read LISST-200X files
% 09/30/14 read zscat, factory zscat and ring areas from
%     200X files. Divides zscat and factory by 10, same as data.
% 10/28/15 include fzs in computing cscat
% 03/17/16 added config record ID and fixed parsing of VCC value
% 07/07/16 use DCAL values stored in file.
%     [vd,dias36,dcal,scat,tau,zsc,data,cscat,fzs] = getscat_L200X('datafile');
% 02/03/16 Major overhaul. Changed how data is read in (no more
%     tt2mat), vectorized cscat computation, corrected auxiliary parameters
% 04/12/17 Added correction at the end of 'parse200XBinary', 
%     allowing for negative ring values. Changed 'config' from a cell array
%     to a structure.
% 10/30/2018 Added VSF calculation
% 03/03/2020 Added analog input 3
% 12/01/2020 Preallocated 'data' matrix in 'parse200XBinary' resulting in
%     massive speed increase for large files. Changed 'while' to 'for'
%     loop in 'parse200XBinary'. Added warning messages.

