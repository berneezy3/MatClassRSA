function y = getImageFilesNew(iconPath)
%-------------------------------------------------------------------
% y = getImageFiles(iconPath)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This is a helper function for the visualization functions
% to retrieve jpg, jpeg, or png files from a directory
%
% INPUT ARGS:
%   iconPath - Absolute or relative path to the images to be used
%               for labeling
%
% OUTPUT ARGS:
%   y - an array of jpg, jpeg, or png file names
%
% EXAMPLES:
%
% TODO:
%   - output warning if no image files found in iconPath

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

    labelStructs = dir(iconPath);
    tempLabelStruct = NaN;
    labels = {};
    for i =1:length(labelStructs)
        tempLabelStruct = labelStructs(i);
        labels = [labels tempLabelStruct.name];
    end
    removeArr = [];
    % remove non-png, non-jpg files
    for i = 1:length(labels)
        if ~(endswith(cell2mat(labels(i)), '.jpg') ...
            || endswith(cell2mat(labels(i)), '.png') ...
            || endswith(cell2mat(labels(i)), '.jpeg') )
            removeArr = [labels(i) removeArr];
        end
    end
    tempLabels = {};
    
    % add all labels not in the remove list into the new array
    for i = 1:length(labels)
        insertFlag = 1;
        for j = 1:length(removeArr)
            %  if string is in removeArray, then dont add it into our
            %  return array
            if strcmp(cell2mat(removeArr(j)), cell2mat(labels(i))) == 1
                insertFlag = 0;
            end
        end
        if insertFlag
            tempLabels = [tempLabels labels(i)];
        end
    end
    y = tempLabels;

end