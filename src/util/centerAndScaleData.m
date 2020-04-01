function [xOut, colMeans, colScales] = centerAndScaleData(xIn, centering, scaling)
% [xOut, colMeans, colScales] = normalizeColumns(xIn, centering, scaling)
% ------------------------------------------------------------------------
% This function takes in a 2D data matrix, and optional centering/scaling
% specifications, and centers and scales each data column as specified.
%
% Inputs
% - xIn (required): 2D data matrix.
%
% - centering (optional): Specification for centering columns of the data.
%   If empty or not specified, will default to true.
%   ----- Acceptable specifications for centering -----
%   - true (default), 1: Center each column through subtraction of the
%     mean.
%   - false, 0: Do not center the data columns.
%   - vector whose length is the number of columns of xIn: The value of
%     each element of this vector will be subtracted from the respective
%     column of xIn. This is useful, for example, when centering test data
%     according to column means computed from the training data.
%   NOTE that if the input data matrix xIn has 1 column and 1 or 0 is
%   specified for centering, the function will print a warning and treat
%   this as a numeric vector input of length 1 (i.e., the user should
%   specify 'true' or 'false' for centering if wishing to use one of those
%   specifications).
%
% - scaling (optional): Specification for scaling columns of the data. If
%   empty or not specified, will default to true.
%   ----- Acceptable specifications for scaling -----
%   - true (default), 1: Scale each column by dividing each column by its
%     standard deviation.
%   - false, 0: Do not scale the data columns.
%   - vector whose length is the number of columns of xIn: Each column of
%     xIn will be divided by the respective value in this vector. This is
%     useful, for example, when scaling test data according to standard
%     deviations computed from the training data.
%   NOTE that if the input data matrix xIn has 1 column and 1 or 0 is
%   specified for centering, the function will print a warning and treat
%   this as a numeric vector input of length 1 (i.e., the user should
%   specify 'true' or 'false' for scaling if wishing to use one of those
%   specifications).
%
% Outputs
% - xOut: The centered and/or scaled data matrix (same size as xIn).
%
% - colMeans: Vector whose length is the number of columns of xIn,
%   representing the value that was subtracted from each column of the
%   input data matrix. This can be used, for example, to apply centering
%   parameters computed from training data onto test data.
%
% - colScales: Vector whose length is the number of columns of xIn,
%   representing the value by which each column of the input data matrix
%   was scaled. This can be used, for example, to apply scaling parameters
%   computed from training data onto test data.

% LICENSE TEXT HERE

% Check for 2D or 3D input; if 3D, reshape to 2D and flag for end reshape.
switch ndims(xIn)
    case 2
        reshapeToCube = 0;
    case 3
        xIn = cube2trRows(xIn);
        reshapeToCube = 1;
    otherwise
        error('Input data should be a 2D or 3D matrix.')
end

% Make sure the input data matrix is numeric.
if ~isnumeric(xIn), error('Input must be numeric.'); end

% Assign centering and scaling to default 'true' if undefined or empty.
if ~exist('centering', 'var') || isempty(centering)
    disp('Centering not specified! Setting to ''true''.'); 
    centering = true; % logical
end
if ~exist('scaling', 'var') || isempty(scaling)
    disp('Scaling not specified! Setting to ''true''.'); 
    scaling = true; % logical
end

% Make sure the scaling and centering parameters are either logical or
% numeric.
if ~(islogical(centering) || isnumeric(centering))
   error('Centering specification should be logical or numeric') 
elseif ~(islogical(scaling) || isnumeric(scaling))
   error('Scaling specification should be logical or numeric') 
end

% If the function call has requested scaling without centering, display a
% warning.
if any(scaling(:)) && ~any(centering(:))
    warning('Scaling data without centering is generally not recommended. Proceed with caution!');
end

% Make sure length of 'centering' and 'scaling' is either 1 or the number 
% of features (where number of features is the number of columns of the 2D 
% input matrix).
expectedCenterScaleVectorSize = size(mean(xIn,1));
if length(centering) ~= 1 && ~isequal(size(centering), expectedCenterScaleVectorSize)
    error(['Second input ''centering'' should be either a logical or a row vector whose ' ...
        'length is the number of columns of ''xIn''.'])
elseif length(scaling) ~= 1 && ~isequal(size(scaling), expectedCenterScaleVectorSize)
    error(['Third input ''scaling'' should be either a logical or a row vector whose ' ...
        'length is the number of columns of ''xIn''.'])
end

% Create the colMeans and colScales vectors:
% colMeans: This value will be subtracted from each column of data.
% colScales: Every column of data will be divided by this value.
%
% Print a warning in the case that the input data matrix has only 1 column,
% and centering and/or scaling was specified as a numeric (not logical)
% input.

% SINGLE-COLUMN INPUT xIn (in 2D form)
if size(xIn, 2) == 1
    
    % Centering, logical specification
    if islogical(centering)
        
        % Set to 0 (no centering) if 'false'; set to column mean if 'true'.
        colMeans = centering * mean(xIn);
    
    % Centering, numeric specification
    else % ~islogical(centering)
        warning(['Input data ''xIn'' is single column and centering '...
            'specification is numeric (' num2str(centering) '). '...
            'The centering specification will be therefore treated as numeric '...
            'during computations. If wishing '...
            'to set centering to ''on'' (subtraction of mean) or ''off'', '...
            'please instead input it as a logical (true or false).'])
        
        % Set to specified numeric value of 'centering'.
        colMeans = centering;
    end
    
    % Scaling, logical specification
    if islogical(scaling)
        
        % Set to 1 (no scaling) if 'false'; set to standard deviation of
        % column if 'true'.
        colScales = std(xIn)^scaling;
    
    % scaling, numeric specification
    else % ~islogical(scaling)
       warning(['Input data ''xIn'' is single column and scaling '...
        'specification is numeric (' num2str(scaling) '). '...
        'The scaling specification will be therefore treated as numeric '...
        'during computations. If wishing '...
        'to set scaling to ''on'' (division by standard deviation) or '...
        '''off'', please instead input it as a logical (true or false).'])
    
        % Set to specified numeric value of 'scaling'.
        colScales = scaling;
    end

% MULTIPLE-COLUMN INPUT xIn (in 2D form)
else
    % Centering, single-element specification. Since we have multiple
    % columns, this isn't specifying a column mean, so we'll convert to
    % logical whether it was a logical or numeric input.
    if length(centering) == 1
        
        % Set to vector of 0 (no centering) if 'false' or 0; set to vector
        % of column means if 'true' or non-zero.
        colMeans = logical(centering) * mean(xIn, 1);
   
    % Centering, vector specification
    else 
        
        % Set to the specified numeric (row) vector.
        colMeans = centering(:)';
    end
    
    % Scaling, single-element specification (logical or numeric)
    if length(scaling) == 1
        
        % Set to vector of 1 (no scaling) if 'false' or 0; set to vector of
        % column standard deviations if 'true' or non-zero.
        colScales = std(xIn, [], 1) .^ logical(scaling);
   
    % Scaling, vector specification
    else
        
        % Set to specified numeric (row) vector.
        colScales = scaling(:)';
    end
end

% Do the centering and scaling!
nTrials = size(xIn, 1);
xCentered = xIn - repmat(colMeans, nTrials, 1);
xOut = xCentered ./ repmat(colScales, nTrials, 1);