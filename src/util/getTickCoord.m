function [xTickVec yTickVec] = getTickCoord()

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

    % use vertical align to plot images/text easily
%{  only works on 2016b and after
    %yCoords = yticks;
    %xCoords = xticks;
%}
    yCoords = get(gca, 'ytick');
    xCoords = get(gca, 'xtick');
    
    yl = ylim;
    yOffset = (yl(2) - yl(1))/25;
    xl = xlim;
    xOffset = (xl(2)-xl(1))/25;
    
    yCoord4xAxis = yl(1) - yOffset;
    xCoord4yAxis = xl(1) - xOffset;
    
    xlen = length(xCoords);
    ylen = length(yCoords);
    
    xTickVec = NaN(xlen, 2);
    yTickVec = NaN(ylen, 2);
 
    for i = 1:xlen
        xTickVec(i,1) = xCoords(i);
        xTickVec(i,2) =  yCoord4xAxis;
    end
    
    for i = 1:ylen
        yTickVec(i,1) = xCoord4yAxis;
        yTickVec(i,2) = yCoords(i);
    end
    

end