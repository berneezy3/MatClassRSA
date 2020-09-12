
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

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

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
plotOnEgi([allElectrodeAccs;NaN;NaN;NaN;NaN])
c = colorbar;
minAll = min(allElectrodeAccs);
maxAll = max(allElectrodeAccs);
c.Ticks = [minAll (minAll+maxAll)/2 maxAll];
c.FontSize = 15;
set(gca, 'clim', [min(allElectrodeAccs) max(allElectrodeAccs)]);
