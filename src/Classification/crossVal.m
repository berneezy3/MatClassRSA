
function z = crossVal(X, Y, varargin)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------

    ip = inputParser;
    ip.FunctionName = 'crossVal';
    ip.addRequired('X',@ismatrix);
    ip.addRequired('Y',@isvector);
    ip.addParameter('nFolds', [], @(x) isnumeric(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});





end