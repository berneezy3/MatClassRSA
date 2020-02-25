function [xNorm, colMeans, colScales] = normalizeColumns(xIn, centering, scaling)
% [xNorm, colMeans, colScales] = normalizeColumns(xIn, centering, scaling)
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
%   specify 'true' or 'false' for centering if wishing to use one of those
%   specifications).
