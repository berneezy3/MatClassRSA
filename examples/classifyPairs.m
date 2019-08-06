
% classifyPairs.m
% -----------------------
% Illustrative example for MatClassRSA toolbox. 
%
% This script loads a Matlab data file that has been downloaded from a 
% public EEG repository (https://purl.stanford.edu/bq914sc3730) and 
% performs all possible pairwise classifications of the stimulus categories
% in the 3D EEG data frame. 
%
% We use the customizable functionalities of the computeRDM function to 
% transform the collection of pairwise accuracies to an RDM. The RDM is 
% then visualized as a matrix image, in an MDS plot, as a dendrogram, and 
% as a minimum spanning tree.

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

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S1.mat.'''))
inDir = uigetdir(pwd);

cd(inDir)
load S6.mat

accMatrix = zeros(6,6);
%%

%%%% Iterate through all the pairs and classify.
for cat1 = 1:5
   for cat2 = (cat1+1):6
      disp([num2str(cat2) ' vs ' num2str(cat1)]) 
      currUse = ismember(categoryLabels, [cat1 cat2]);
      
      % Store the accuracy in the accMatrix
      C = classifyCrossValidate(...
          X_3D(:, :, currUse), categoryLabels(currUse), 'randomSeed', 'default');
      
      acc = C.accuracy;
      accMatrix(cat2, cat1) = acc;
      predY = C.predY;
      pVal = C.pVal;
      classifierInfo = C.classifierInfo;
      
   end
end

%%%% Costruct the RDM using optional name-value pairs.
% We set 'normalize' to 'none' because values on the diagonal are already
% zero (self-distance is zero). We can symmetrize with 'average' because we
% don't care about the actual distance values (accuracies) but will rather
% convert to ranks later. We don't need to convert to distances because
% unlike confusions, accuracies already serve as distance measures.
% Finally, we convert to rank distances.
%%
RDM = computeRDM(accMatrix, 'normalize', 'none',...
    'symmetrize', 'mean', 'distance', 'none',...
    'rankdistances', 'rank');

% % Create the four visualizations
f1 = plotMatrix(RDM, 'matrixLabels', 1, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f2 = plotMDS(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f3 = plotDendrogram(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f4 = plotMST(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });