function scaledData = scaleDataShiftDivide(data, shift1, shift2, scaleFactor)
% scaledData = scaleDataShiftDivide(data, shift, divide)
% -------------------------------------------------------------------------
% Bernard - February 25, 2020
%
% This function takes in the data matrix data and a shift and divide factor
% calculated from the function scaleDataInRange().  The function applies
% the shift and divide factor on the data matrix to center the data around
% 0, within a range set in scaleDataInRange()
% 
% INPUTS
%   data: Input numeric data matrix.
%   shift: Shift factor to zero center the data matrix.  This value should
%   be an output from scaleDataInRange().
%   divide: Scaling factor to ensure that all values in the data matrix
%   fall with a certain range.  The range is specified in
%   scaleDataInRange(), and the divide factor should be be an output from 
%   scaleDataInRange().
%
% OUTPUTS
%   scaledData:  the data matrix that is zero-centered and scaled
%   according to the input parameters
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

    scaledData = (data - shift1).*scaleFactor + shift2;

end