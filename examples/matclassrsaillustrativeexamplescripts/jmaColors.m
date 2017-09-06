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



    