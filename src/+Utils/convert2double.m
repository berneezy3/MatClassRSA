function [X, Y] = convert2double(X, Y)
%-------------------------------------------------------------------
%  [X, Y] = convert2double(X, Y)
%-------------------------------------------------------------------
%
% This function converts user data into double format
%
% REQUIRED INPUTS:
%       X - data matrix. Can be either a 2D (trial x feature) or
%           3D (space x time x trial) matrix.
%       Y - labels vector. Length should match the length of the trials
%           dimension of X.
%
% OUTPUTS:
%       X - Converted data matrix (double format). Can be either a 2D (trial x feature) or
%           3D (space x time x trial) matrix.
%       Y - Converted labels vector (double format). Length should match the length of the trials
%           dimension of X.
% Bernard - June. 27, 2020, Ray - Edit Sept, 2023

   if ~isa(X, 'double')
       warning('X data matrix not in double format.  Converting X values to double.')
       disp('Converting X matrix to double')
       X = double(X); 
   end
   if ~isa(Y, 'double')
       warning('Y label vector not in double format.  Converting Y labels to double.')
       Y = double(Y);
       disp(Y);
   end

end