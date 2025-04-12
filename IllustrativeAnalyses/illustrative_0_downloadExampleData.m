% illustrative_0_downloadExampleData.m
% ----------------------------------------
% Blair - April 12, 2025
%
% TODO BEFORE V2 RELEASE
% - Blair: Upload Nathan's version of cleaned data (e.g., S01) to SDR and
%   update download URL in this script.
% - Update "filesToCheck" variable so that it only has the 2 data files. It
%   currently also looks for "exampleCM.mat" (which is already in the
%   folder) to verify that that logic path is working. 
%
% This script looks in the "ExampleData" folder of the local instance of
% the toolbox; if the user does not have the .mat files containing example
% EEG data needed to run the illustrative analyses, the script will
% download said files into this folder.
%
% The following data files are not included with MatClassRSA due to their
% size and will be downloaded if not already found in the "ExampleData"
% folder:
%   1. S01.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   2. losorelli_100sweep_epoched.mat -- single-channel EEG representing
%   responses from TODO FILL IN MORE.
%
% The .gitignore file of the repository specifies that these two files are
% to be ignored.
%
% More information about these data files, and links to related literature,
% can be found in the MatClassRSA user manual.
%
% NOTE: If multiple instances of MatClassRSA are in the Matlab path, the
% function will print a warning and download the files into the first
% instance that was indexed. This may result in the .mat files being
% downloaded to an unintended location.

clear all; close all; clc

%%% Get path(s) to the "ExampleData" folder in the MatClassRSA toolbox.
edFolder = what(['MatClassRSA' filesep 'ExampleData']);

% We need exactly one path to check and possibly download data into.
if length(edFolder) == 0
    error('"ExampleData" folder not found. Make sure that MatClassRSA is on your local machine and added to the Matlab path.')
elseif length(edFolder) > 1
    edFolder = edFolder(1);
    warning(['More than one instance of "ExampleData" was found on the local machine. If data files need to be downloaded, they will be downloaded to the first indexed directory: ' newline edFolder.path])
end

%%% Check for each data file and download if not already there
filesToCheck = {'S01.mat', 'losorelli_100sweep_epoched.mat', 'exampleCM.mat'};
fileURLs = {'https://ccrma.stanford.edu/~blairbo/S01.mat', 'https://stacks.stanford.edu/file/cp051gh0103/losorelli_100sweep_epoched.mat'};
nFilesDownloaded = 0;

for f = 1:length(filesToCheck)
    currFile = filesToCheck{f};
    disp(['File ' num2str(f) ' of ' num2str(length(filesToCheck))])
    if ~exist(fullfile(edFolder.path, currFile))
        disp(['Downloading ' currFile ' to ' edFolder.path newline])
        websave(fullfile(edFolder.path, currFile), fileURLs{f});
        nFilesDownloaded = nFilesDownloaded + 1;
    else
        disp([currFile ' already found in ' edFolder.path newline])
    end

end

disp(['\ * \ * Run complete. ' num2str(nFilesDownloaded) ' file(s) downloaded. * / * /'])