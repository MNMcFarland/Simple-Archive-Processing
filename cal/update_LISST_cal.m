function [lisstCal] = update_LISST_cal(lisstCal,bkgdFileName)

%update_LISST_cal()
%   This function takes a lisst cal file and updates it with the new
%   background data save from LISST.
% 
%   lisstCal = .mat calibration file for LISST
%   newBkgdFile = name of background file file saved from LISST

% Prep data
bkgdMat = readmatrix(bkgdFileName,'FileType','text')';
bkgdMat(1:36) = bkgdMat(1:36) .* 10; % getscat_L200X.m multiplies background (zsc) by 10 when first loading (see function). I think to convert it to counts.
dt = datetime(bkgdMat(43:48));

% Add data to info table and to zsc in lisst cal file
lisstCal.zsc = [lisstCal.zsc;bkgdMat]; % add to zsc

[~,nm,ext] = fileparts(bkgdFileName);
FileName = [lisstCal.info.FileName; [nm ext]];
% FileName = [lisstCal.info.FileName; bkgdFileName];
zscDate = [lisstCal.info.zscDate;dt'];
T = table(FileName,zscDate);
lisstCal.info = T;  % add to info


end