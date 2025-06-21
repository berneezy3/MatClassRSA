function [xTickVec yTickVec] = getTickCoord()
%-------------------------------------------------------------------
% [xTickVec yTickVec] = getTickCoord()
% ------------------------------------------------------------------
%
% This function gets the x,y coordinates of the ticks of the plot.  This is
% a helper function to the visualization classes
% 
% INPUT ARGS:
%   N/A
%
% OUTPUT ARGS:
%   - xTickVec:  x coordinates of ticks
%   - yTickVec: y coordinates of ticks

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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