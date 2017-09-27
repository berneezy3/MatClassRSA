
% classifySingleElectrodes.m
% -----------------------------
% Illustrative example for MatClassRSA toolbox. 
%
% This script loads a Matlab data file that has been downloaded from a 
% public EEG repository (https://purl.stanford.edu/bq914sc3730) and 
% performs category-level (6-class) classifications on the data from one
% electrode at a time. The resulting collection of classifier accuracies
% are then plotted on a scalp map.
%
% This script requires the electrodes location file 
% "Hydrocel GSN 128 1.0.sfp", the custom helper function getLocs124, and 
% the readlocs and topoplot functions from the EEGLAB toolbox. All of 
% these necessary files are provided with the MatClassRSA toolbox.
%
% (c) Bernard Wang and Blair Kaneshiro, 2017. 
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);

cd(inDir)
load S6.mat

allElectrodeAccs = nan(124, 1);

%%%% Iterate through all the electrodes and classify
for i = 1:124
   [CM, allElectrodeAccs(i), predY, pVal, classifierInfo] = classifyEEG(...
       X_3D(i,:,:), categoryLabels, 'randomSeed', 'default');
end

%%

%%%% Plot the accuracies on a scalp map
%l = getLocs124();
%topoplot(allElectrodeAccs, l); 
plotOnEgi([allElectrodeAccs;NaN;NaN;NaN;NaN])
c = colorbar;
minAll = min(allElectrodeAccs);
maxAll = max(allElectrodeAccs);
c.Ticks = [minAll (minAll+maxAll)/2 maxAll];
c.FontSize = 15;
set(gca, 'clim', [min(allElectrodeAccs) max(allElectrodeAccs)]);
