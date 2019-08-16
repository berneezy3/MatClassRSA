function [cmap] = jmaColors(mapName,thresh,nPoints);
%function [cmap] = jmaColors(mapName,thresh,nPoints);
%
%possible map names:
%
%'arizona'       = Blue to Red with white in the middle
%'Air force'     = dark blue to white
%'USC'           = Cardinal to Gold
%'Cal'           = Blue to Yellow
%'Nebraska'      = White to Red;
%'italy'         = Green to White to Red             
%'hotcortex'     = gray to red to yellow
%'coolhotcortex' = cyan to blue to gray to red to yellow
%'pval'          = yellow to red

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Spero Nicholas (with input from Justin Ales and Benoit
% Cottereau)
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


if ~exist('nPoints','var') || isempty(nPoints),
    
    nPoints = 64;
end




xi = linspace(0,1,nPoints);

switch lower(mapName)

    case 'air force'

        colorVal = [ 0 0 102; ...
           230 245 255]/255;

        colorLoc = [0 0 0; ...
            1 1 1];
    

    case {'arizona', 'usa'}
     
        colorVal = [0 0 1;
                    1 1 1;
                    1 0 0;];
                
        colorLoc = [0 0 0;
                    .5 .5 .5;
                    1 1 1;];
    
                
    case  'usadarkblue'
     
        colorVal = [.2 .27 .67;
                    1 1 1;
                    1 0 .094;];
                
        colorLoc = [0 0 0;
                    .5 .5 .5;
                    1 1 1;];
                

    case 'italy'
     
        colorVal = [0 .5 0;
                    1 1 1;
                    1 0 0;];
                
        colorLoc = [0 0 0;
                    .5 .5 .5;
                    1 1 1;];
                
    case 'usc'

        colorVal = [ 150 0 0; ...
            255 255 0]/255;

        colorLoc = [0 0 0; ...
            1 1 1];
    

    case 'cal'

        colorVal = [ 0 0 200; ...
            255 255 0]/255;

        colorLoc = [0 0 0; ...
            1 1 1];
        
        
    case 'nebraska'
     
        colorVal = [1 1 1;
                    1 0 0;];
                
        colorLoc = [0 0 0;                    
                    1 1 1;];
        
    case 'hotcortex'

        colorVal = [.6 .6 .6; 
            1 0 0;
            1 1 0;];
        
        colorLoc = [0 0 0;
                    .5 .5 .5;
                    1 1 1;];

        
    case 'coolhotcortex'
     
        colorVal = [0 1 1; 
                    0 0 1; 
                    .6 .6 .6;
                    1 0 0;
                    1 1 0;];
                
        colorLoc = [0 0 0;
                    .25 .25 .25;
                    .5 .5 .5;
                    .75 .75 .75;
                    1 1 1;];

    case 'pval'

        colorVal = [...
            1 1 0;
            1 0 0;];
            
        
        colorLoc = [0 0 0; 
                    1 1 1;];

    otherwise
        error(['Sorry cannot find matching colormap named: ' mapName ])
end


for i=1:3,
    cmap(:,i) = interp1(colorLoc(:,i),colorVal(:,i),xi)';
end

if exist('thresh','var') && ~isempty(thresh)
    
    nThresh = round((thresh*nPoints)/(1-thresh));
    threshColor = .5;
    
    cmap = [threshColor*ones(nThresh,3);cmap];
    
end



    