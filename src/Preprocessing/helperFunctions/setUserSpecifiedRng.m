function setUserSpecifiedRng(r)
% setUserSpecifiedRng(r)
% -------------------------------
% Blair Kaneshiro - August 14, 2019
%
% This function sets the random number generator according to the input r.
%
% INPUT
%   r: Random number generator (rng) specification. It can be a single
%       input of the type accepted by the rng function (e.g., 1, 'default')
%       or, for dual-argument specifications, either a 2-element cell
%       array (e.g., {'shuffle', 'twister'}) or string array (e.g.,
%       ["shuffle", "twister"]. If a single input (seed) is provided, the
%       function will set the generator to 'twister'.
% OUPUT
%   none.
%
% If r is empty, NaN, or not specified, the function will print a warning
% and set rng to {'shuffle', 'twister'}.

if nargin < 1 || isempty(r) || (length(r) == 1 && isnan(r))
    warning('Nothing input to ''setUserSpecifiedRng'' function. Setting rng=(''shuffle'', ''twister'').');
    rng('shuffle', 'twister');
    return
end

rng('default'); % making sure the generator is 'twister'

if length(r) == 2
    if isnumeric(str2double(r{1}))
        rng(str2double(r{1}), r{2});
    else
        rng(r{1}, r{2});
    end
    
    % Display a message stating what type of rng we are using.
    try
        disp(['Shuffling averaged data using rng=' mat2str(r) '.']);
    catch
        disp(['Shuffling averaged data using rng={''' r{1} ''', ''' r{2} '''}.' ]);
    end
elseif ischar(r) || length(r) == 1
    rng(r);
    disp(['Shuffling averaged data using rng=(' mat2str(r) ', ''twister'').']);
else
    error('Rng specification should be a single value or cell/string array of length 2.');
end
rng