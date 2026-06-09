% load LISST calibration file
load lisst200x02059_cal
pth = fileparts(which('lisst200x02059_cal.mat'));

d = dir('lisst_calibrations\*.bgt');
temp = lisst200x02059_cal;
for m = 1:length(d)
    temp = update_LISST_cal(temp,[d(m).folder filesep d(m).name]);
end

% run function to update lisst cal file with new background file
% temp = update_LISST_cal(lisst200x02059_cal,'20250124_background.bgt');

% Check to make sure everything ran correctly. If so, save new cal data out.
lisst200x02059_cal = temp;
% save('lisst200x02059_cal.mat','lisst200x02059_cal')
save([pth filesep 'lisst200x02059_cal.mat'],'lisst200x02059_cal')





