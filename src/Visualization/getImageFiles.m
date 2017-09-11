function y = getImageFilesNew(iconPath)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
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