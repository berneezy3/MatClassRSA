function y = getImageFiles(iconPath)
%-------------------------------------------------------------------
% y = getImageFiles(iconPath)
% ------------------------------------------------
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
% TODO:
%   - output warning if no image files found in iconPath

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
        if ~(Utils.endswith(cell2mat(labels(i)), '.jpg') ...
            || Utils.endswith(cell2mat(labels(i)), '.png') ...
            || Utils.endswith(cell2mat(labels(i)), '.jpeg') )
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