function verifySVMParameters(ip)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% verifySVMParameters(ip)
% --------------------------------
% Bernard Wang, Sept 28, 2019
%
% This function is used for the non-optimization classification functions
% (crossValidateMulti, crossValidatePairs, trainPairs, trainMulti) to
% ensure that gamma and C parameters are manually set by the user when
% using the SVM classifier
%
% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
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

    if (strcmp(ip.Results.classifier, 'SVM'))
        
        if(strcmp(ip.Results.kernel, 'rbf'))
            if any(strcmp(ip.UsingDefaults, 'C')) || any(strcmp(ip.UsingDefaults, 'gamma')) 
                error(['if SVM is selected as classifier with rbf kernel, then "C" and "gamma" ' ...
                'parameters must be manually set by the user.  Suitable values for'...
                ' "C" and "gamma" can determined using the optimization functions '...
                'in the classifiction folder denoted by the "_opt" postscript. ' ...
                'Then "C" and "gamma" can be passed into this function directly"']);
            end
            
        elseif (strcmp(ip.Results.kernel, 'linear'))
            if any(strcmp(ip.UsingDefaults, 'C'))
                error(['if SVM is selected as classifier with linear kernel, then "C"' ...
                'parameter must be manually set by the user.  Suitable values for'...
                ' "C" can determined using the optimization functions '...
                'in the classifiction folder denoted by the "_opt" postscript. ' ...
                'Then "C" can be passed into this function directly"']);
            end
        end
        
    end



end