function distanceMatrix = computeDistanceMatrix(CM, varargin)
% distanceMatrix = computeDistanceMatrix(CM, varargin)
% ------------------------------------------------
% Blair - January 31, 2017
%
% This function takes in a confusion matrix and converts
% it to a distance matrix.
%
% Required inputs:
% - CM: A square confusion matrix
%
% Optional inputs:
% - distpower: Integer > 0 (if using 'power' or 'log' distance)
%
% Optional name-value pairs:
% - 'normalize': 'diagonal' (default), 'sum', 'none'
% - 'symmetrize': 'average' (default),
%   'geometric', 'harmonic', 'none'
% - 'distance': 'linear' (default), 'power',
%   'logarithmic', 'none'
% - 'rankdistances': 'none' (default), 'rank', 'percentrank'
%
% Outputs:
% - DM: The distance matrix
%
% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers: https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers

% Initialize the input parser
ip = inputParser;
ip.CaseSensitive = false;

% Specify default values
defaultDistpower = 1;
defaultNormalize = 'diagonal';
defaultSymmetrize = 'arithmetic';
defaultDistance = 'linear';
defaultRankdistances = 'none';

% Specify expected values
expectedNormalize = {'diagonal', 'sum', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};

% Required inputs
addRequired(ip, 'CM', @isnumeric)

% Optional inputs
addOptional(ip, 'distpower', defaultDistpower, @isnumeric);

% Optional name-value pairs
% NOTE: Should use addParameter for R2013b and later.
if verLessThan('matlab', '8.2')
    addParamValue(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParamValue(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParamValue(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParamValue(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
else
    addParameter(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParameter(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParameter(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParameter(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
end


% Parse
parse(ip, CM, varargin{:});

% Verify the confusion matrix is square
if size(CM, 1) ~= size (CM, 2)
    error('The input confusion matrix should be square.')
end

disp('Computing distance matrix...')

% NORMALIZE
NM = normalizeMatrix(CM, ip.Results.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, ip.Results.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, ip.Results.distance, ip.Results.distpower);

% RANKDISTANCES
distanceMatrix = rankDistances(DM, ip.Results.rankdistances);
