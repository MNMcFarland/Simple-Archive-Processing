function [] = splitPackageData(data,folderPath)
% splitPackageData = split the optical package data into its respective
% folder
%   This function will take the "s" output of the IPP processed data, clean
%   up each archive into final processed results, and create new station
%   folders to save data to.
%   
%   data       = "s" data output from IPP
%   folderPath = path to "processed" folder


% clean up data
cleanS = cleanPackageData(data,'IRLNEP');

% get sensor plots
% sensorPlotPath = [pwd,'\Optical Package\IPP_code\sensor_plots\'];
% cd(sensorPlotPath);
% plotNames = dir(sensorPlotPath);
% if isempty(plotNames)
%     plotNames = dir('*.png');
% end
% plotNames = {plotNames(:).name}';

% get station names
fNames = fieldnames(cleanS);
for xx = 1:numel(fNames)
    temp = strsplit(fNames{xx},'_');
    stnTemp(xx) = temp(3);
end


% create folders to save data 
for xx = 1:numel(fNames)
    
    savePath = [folderPath,'\'];
%     cd(savePath)

    % if processed folder doesnt exist then make one
    if ~exist(savePath,'dir')
        mkdir(savePath) 
    end
%     savePath = [savePath'\'];
    
    
    % if station folder doesn't exist then make one
    if ~exist(stnTemp{xx},'dir')
        mkdir(stnTemp{xx}) 
    end
    savePath = [savePath,stnTemp{xx},'\'];
%     cd(savePath)

%     % if EARL folder doesn't exist then make one
%     if ~exist('EARL','dir')
%         mkdir('EARL')
%     end
%     savePath = [savePath,'EARL\'];
%     cd(savePath)
    
    % if IPP_output folder doesn't exist then make one
%     if ~exist('IPP_output','dir')
%         mkdir('IPP_output')
%     end
%     savePath = [savePath,'IPP_output\'];
%     cd(savePath)

    % save out the data into folder
    save([savePath,fNames{xx},'.mat'],'-struct','cleanS',fNames{xx})

    % save copy of sensor plot to folder
%     whichPlot = plotNames(contains(plotNames,stnTemp{xx}));
%     if ~isempty(whichPlot)
%         copyfile([sensorPlotPath,whichPlot{1}],savePath)
%     end
    
end

cd(folderPath)

end

