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

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2019 Bernard C. Wang, Nathan C. L. Kong, Anthony M. Norcia, 
% and Blair Kaneshiro
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

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
            disp(['Setting rng=(' num2str(str2double(r{1})) ',' r{2} ').']);
        else
            rng(r{1}, r{2});
%             disp('debug 2')
            disp(['Setting rng=(''' r{1} ''', ''' r{2} ''').' ]);
        end
    elseif iscell(r) % Assignment and formatting for cell array input
        rng(r{1}, r{2});
%         disp('debug 3')
        if isnumeric(r{1})
            disp(['Setting rng=(' num2str(r{1}) ', ''' r{2} ''').' ]);
        else
            disp(['Setting rng=(''' r{1} ''', ''' r{2} ''').' ]);
        end
    else
        error('Two-argument rng specifications should be as string array or cell array.');
    end
    
elseif ischar(r) || length(r) == 1
    try
        rng(r);
%         disp('debug 4')
        if isequal(r, 'default')
            disp(['Setting rng=(' mat2str(r) ').']);
        else
            disp('Single-input rng specification: Setting generator to ''twister''.')
            disp(['Setting rng=(' mat2str(r) ', ''twister'').']);
        end
    catch
        error('Rng specification should be a single value, or cell/string array of length 2, containing acceptable rng parameters.');
    end
else
    error('Rng specification should be a single value, or cell/string array of length 2, containing acceptable rng parameters.');
end