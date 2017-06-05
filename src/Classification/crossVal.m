
function z = crossVal(X, Y, varargin)

    ip = inputParser;
    ip.FunctionName = 'crossVal';
    ip.addRequired('X',@ismatrix);
    ip.addRequired('Y',@isvector);
    ip.addParameter('nFolds', [], @(x) isnumeric(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});





end