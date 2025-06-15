% illustrative_0_downloadExampleData.m
% ----------------------------------------
% This script looks in the "ExampleData" folder of the local instance of
% the toolbox; if the user does not have the .mat files containing example
% EEG data needed to run the illustrative analyses, the script will
% download said files into this folder.
%
% The following data files are not included with MatClassRSA due to their
% size and will be downloaded if not already found in the "ExampleData"
% folder. The order below denotes the order in which they are indexed and
% will be searched for and downloaded (if needed) by default. The user can
% customize the fileIdx variable on line 109 below with the specific item 
% numbers they wish to check for and download, if they do not need the 
% whole set. 
%   1. S01.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   2. S04.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   3. S05.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   4. S06.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   5. S08.mat -- 124-channel EEG recorded from one participant who viewed
%   each of 72 images 72 times (5184 trials total).
%   6. OCEDStimuli.zip -- Archive containing stimulus images for the OCED
%   data. If downloaded, the archive will be unzipped. 
%   7. losorelli_100sweep_epoched.mat -- single-channel EEG representing
%   frequency-following responses from 13 participants. For each
%   participant, this .mat file contains 25 100-sweep averages for each of
%   six short auditory stimuli (1950 100-sweep averages total).
%   8. MatClassRSA_v2_ExampleData_README.pdf -- informational document
%   describing the dataset. 
%
% The script may take a few minutes to run depending on files selected and 
% the user's download speed.  
%
% NOTE: If multiple instances of MatClassRSA are in the Matlab path, the
% function will print a warning and download the files into the first
% instance that was indexed. This may result in the .mat files being
% downloaded to an unintended location.
%
% The .gitignore file of the repository specifies that these files will
% remain untracked by Git. 
%
% For more information: 
% - Link to data deposit: https://purl.stanford.edu/kv831rr3606
% - Please cite the dataset if using any of the data files for outside
%   projects:
%       Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, Feng Ruan, 
%       Anthony M. Norcia, and Blair Kaneshiro (2025). Example Data for 
%       MatClassRSA v2 Release. Version 1. Stanford Digital Repository. 
%       Available at https://purl.stanford.edu/kv831rr3606/. 
%       https://doi.org/10.25740/kv831rr3606.
% - More information about the data, and links to related literature, can 
%   be found in the MatClassRSA user manual in the GitHub repo. 

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

clear all; close all; clc

%%% Get path(s) to the "ExampleData" folder in the MatClassRSA toolbox.
edFolder = what(['MatClassRSA' filesep 'ExampleData']);

% We need exactly one path to check and possibly download data into.
if length(edFolder) == 0
    error('"ExampleData" folder not found. Make sure that MatClassRSA is on your local machine and that the entire repo is added to the Matlab path.')
elseif length(edFolder) > 1
    edFolder = edFolder(1);
    warning(['More than one instance of "ExampleData" was found on the local machine. If data files need to be downloaded, they will be downloaded to the first indexed directory: ' newline edFolder.path])
end

%%% Create the struct array with URL and filename information

% Calls a helper function in this script
INFO = createInfoStruct;

%%% Specify which files to check for and download if needed

% Default vector (all files)
fileIdx = 1:length(INFO);
nFilesAll = length(fileIdx); % For printing messages later

%%%%%%%%%%%%%%%%%%%%% OPTIONAL USER SPECIFICATION %%%%%%%%%%%%%%%%%%%%%%%%

% If the user does not need to check for/download all files in the list,
% they can specify a subset of file numbers here, which will overwrite
% the default list. Otherwise, comment out the line below.

% fileIdx = [1 2 3 4 5 6 7 8];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check for each data file and download if not already there
nFilesDownloaded = 0;
nFiles = length(fileIdx);

for f = 1:nFiles
    currIdx = fileIdx(f);
    currURL = INFO(currIdx).url;
    currFN = INFO(currIdx).fn;
    disp(['File ' num2str(currIdx) ' of ' num2str(nFilesAll)])
    if ~exist(fullfile(edFolder.path, currFN))
        if currIdx == 6     % OCED image set
            disp(['Downloading (and unzipping) ' currFN ' to ' edFolder.path newline])
        else        % Anything else
            disp(['Downloading ' currFN ' to ' edFolder.path newline])
        end
        websave(fullfile(edFolder.path, currFN), currURL);
        nFilesDownloaded = nFilesDownloaded + 1;

        % If downloading OCED stimuli, also unzip into "ExampleData"
        if currIdx == 6
            unzip(fullfile(edFolder.path, currFN), edFolder.path);
        end

    else
        disp([currFN ' already found in ' edFolder.path newline])
    end

end

disp(['\ * \ * Run complete. ' num2str(nFilesDownloaded) ' file(s) downloaded. * / * /'])

%% Helper function

function INFO = createInfoStruct()

% This is a struct array. Each element has the (1) download URL and 
% (2) name of to-be-saved file for the items in the SDR repository. To
% check for and/or download only select files, edit the fileIdx variable 
% in line 109 above. 

% Index 1: S01.mat
INFO(1).url = 'https://stacks.stanford.edu/file/kv831rr3606/S01.mat';
INFO(1).fn = 'S01.mat';

% Index 2: S04.mat
INFO(2).url = 'https://stacks.stanford.edu/file/kv831rr3606/S04.mat';
INFO(2).fn = 'S04.mat';

% Index 3: S05.mat
INFO(3).url = 'https://stacks.stanford.edu/file/kv831rr3606/S05.mat';
INFO(3).fn = 'S05.mat';

% Index 4: S06.mat
INFO(4).url = 'https://stacks.stanford.edu/file/kv831rr3606/S06.mat';
INFO(4).fn = 'S06.mat';

% Index 5: S08.mat
INFO(5).url = 'https://stacks.stanford.edu/file/kv831rr3606/S08.mat';
INFO(5).fn = 'S08.mat';

% Index 6: OCEDStimuli.zip
% If this file is download, Matlab will additionally unzip it
INFO(6).url = 'https://stacks.stanford.edu/file/kv831rr3606/OCEDStimuli.zip';
INFO(6).fn = 'OCEDStimuli.zip';

% Index 7: losorelli_100sweep_epoched.mat
INFO(7).url = 'https://stacks.stanford.edu/file/kv831rr3606/losorelli_100sweep_epoched.mat';
INFO(7).fn = 'losorelli_100sweep_epoched.mat';

% Index 8: MatClassRSA_v2_ExampleData_README.pdf
% This is the README for the data deposit (not a data file)
INFO(8).url = 'https://stacks.stanford.edu/file/kv831rr3606/MatClassRSA_v2_ExampleData_README.pdf';
INFO(8).fn = 'MatClassRSA_v2_ExampleData_README.pdf';

end