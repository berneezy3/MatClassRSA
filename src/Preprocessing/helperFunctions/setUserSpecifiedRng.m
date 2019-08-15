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

% If the input is a struct containing settings of a random number
% generator, assign it and return.
if nargin == 1 && isstruct(r)
    try
        rng(r);
        disp('Assigning user-specified rng struct:')
        rng
        return;
    catch
        error('If user-specified rng input is a struct, it must be an rng specification.');
    end
end

% Handle edge case of single input (incorrectly) as string array.
if nargin >= 1 && length(r)==1 && isstring(r), r = r{1}; end

% If input is not specified, default to ('shuffle', 'twister').
if nargin < 1 || isempty(r) || (length(r) == 1 && isnan(r))
    warning('Random number generator not specified. Setting rng=(''shuffle'', ''twister'').');
    rng('shuffle', 'twister');
    return
end

% Revert to 'default' since 'twister' is the default generator
rng('default');

if length(r) == 2
    if isequal(r{1}, 'default')
        error('Dual-input rng specification is not allowed with ''default''.')
    end
    
    if isstring(r) % Assignment and formatting for string array input
        if isnumeric(str2double(r{1})) && ~isnan(str2double(r{1}))
            rng(str2double(r{1}), r{2});
%             disp('debug 1')
            disp(['Shuffling averaged data using rng=(' num2str(str2double(r{1})) ',' r{2} ').']);
        else
            rng(r{1}, r{2});
%             disp('debug 2')
            disp(['Shuffling averaged data using rng=(''' r{1} ''', ''' r{2} ''').' ]);
        end
    elseif iscell(r) % Assignment and formatting for cell array input
        rng(r{1}, r{2});
%         disp('debug 3')
        if isnumeric(r{1})
            disp(['Shuffling averaged data using rng=(' num2str(r{1}) ', ''' r{2} ''').' ]);
        else
            disp(['Shuffling averaged data using rng=(''' r{1} ''', ''' r{2} ''').' ]);
        end
    else
        error('Two-argument rng specifications should be as string array or cell array.');
    end
    
elseif ischar(r) || length(r) == 1
    try
        rng(r);
%         disp('debug 4')
        if isequal(r, 'default')
            disp(['Shuffling averaged data using rng=(' mat2str(r) ').']);
        else
            disp('Single-input rng specification: Setting generator to ''twister''.')
            disp(['Shuffling averaged data using rng=(' mat2str(r) ', ''twister'').']);
        end
    catch
        error('Rng specification should be a single value, or cell/string array of length 2, containing acceptable rng parameters.');
    end
else
    error('Rng specification should be a single value, or cell/string array of length 2, containing acceptable rng parameters.');
end