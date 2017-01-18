%
% Normalizes a matrix
% 
% Arguments:
% m - The square matrix to normalize
% method - The normalization method. This should be one of "r.diagonal", "r.sum", "c.diagonal", "c.sum". Default is "r.diagonal".
%
% Details:
% TODO: explain normalization methods
%
function y = normalizeMatrix(m, varargin)  

    ip = inputParser;
    ip.FunctionName = 'normalizeMatrix';
    ip.addRequired('m',@ismatrix);
    options = [1, 0];
    ip.addParameter('sum', 0, @(x) ismember(x, options)); 
    ip.addParameter('diagonal', 1, @(x) ismember(x, options));
    parse(ip,m,varargin{:});
       
  
  if (ip.Results.sum == 1)  % divide each row by the sum of the row
    nrm = m ./ sum(m, 2);
  end
    
  if (ip.Results.diagonal == 1)  % divide each row by main diagonal element
    nrm = m ./ diag(m);
  end
  y = nrm;
end