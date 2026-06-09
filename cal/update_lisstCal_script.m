% load LISST calibration file
load lisst200x02059_cal
cpth = fileparts(which('lisst200x02059_cal.mat'));

% run function to update lisst cal file with new background file
[fnm,fpth] = uigetfile('*.bgt');
temp = update_LISST_cal(lisst200x02059_cal,[fpth fnm]);
% temp = update_LISST_cal(lisst200x02059_cal,'20250124_background.bgt');

% add multiple cals to lisst cal file
% d = dir('lisst_calibrations\*.bgt');
% temp = lisst200x02059_cal;
% for m = 1:length(d)
%     temp = update_LISST_cal(temp,[d(m).folder filesep d(m).name]);
% end

% Check to make sure everything ran correctly. If so, save new cal data out.
lisst200x02059_cal = temp;
% save('lisst200x02059_cal.mat','lisst200x02059_cal')
save([cpth filesep 'lisst200x02059_cal.mat'],'lisst200x02059_cal')


