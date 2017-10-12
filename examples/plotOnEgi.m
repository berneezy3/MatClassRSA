function [plotH,colorH,roiH] = plotOnEgi(data,colorbarLimits,showColorbar,sensorROI,doText,markerProps)
% mrC.plotOnEgi - Plots data on a standarized EGI net mesh
% function meshHandle = mrC.plotOnEgi(data)
%
% This function will plot data on the standardized EGI mesh with the
% arizona colormap.
%
% Data must be a 128 dimensional vector, but can have singleton dimensions,
%
%

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


if nargin<2
    colorbarLimits = [min(data(:)),max(data(:))];    
    newExtreme = max(abs(colorbarLimits));
    colorbarLimits = [-newExtreme,newExtreme];
end
if nargin<3
    showColorbar = false;
end
if nargin<4
    sensorROI = 0;
end
if nargin<5
    doText = false;
else
end
if nargin<6
    if doText
        markerProps = {'facecolor','none','edgecolor','none','markersize',15,'marker','o','markerfacecolor','w','MarkerEdgeColor','k','LineWidth',.5};
    else
        markerProps = {'facecolor','none','edgecolor','none','markersize',6,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    end
else
end

if doText && sensorROI ==0
    warning('no sensor ROI specified');
else
end

data = squeeze(data);
datSz = size(data);

if datSz(1)<datSz(2)
    data = data';
end

if size(data,1) == 128
    tEpos = load('defaultFlatNet.mat');
    tEpos = [ tEpos.xy, zeros(128,1) ];
    
    tEGIfaces = mrC_EGInetFaces( false );
    
    nChan = 128;
elseif size(data,1) == 256
    
    tEpos = load('defaultFlatNet256.mat');
    tEpos = [ tEpos.xy, zeros(256,1) ];
    
    tEGIfaces = mrC.EGInetFaces256( false );
    nChan = 256;
elseif size(data,1) == 32
    tEpos = load('defaultFlatNet32.mat');
    tEpos = [ tEpos.xy, zeros(32,1) ];
    
    tEGIfaces = mrC.EGInetFaces32( false );
    
    nChan = 32;
    
else
    error('Only good for 3 montages: Must input a 32, 128 or 256 vector')
end


patchList = findobj(gca,'type','patch');
netList   = findobj(patchList,'UserData','plotOnEgi');


if isempty(netList),    
    plotH = patch( 'Vertices', [ tEpos(1:nChan,1:2), zeros(nChan,1) ], ...
        'Faces', tEGIfaces,'EdgeColor', [ 0.5 0.5 0.5 ], ...
        'FaceColor', 'interp');
    axis equal;
    axis off;
else
    plotH = netList;
end

set(plotH,'facevertexCdata',data,'linewidth',0.5,'markersize',4,'marker','.');
set(plotH,'userdata','plotOnEgi');

if sensorROI ~= 0
    vertexLoc = get(plotH,'Vertices'); % vertex locations
    roiLoc = vertexLoc(sensorROI,:);
    roiH = patch(roiLoc(:,1),roiLoc(:,2),roiLoc(:,3),'o');
    set(roiH,markerProps{:});
    if doText
        roiX = get(roiH,'XData');
        roiY = get(roiH,'YData');
        roiZ = get(roiH,'ZData');
        arrayfun(@(x) ...
            text(roiX(x),roiY(x),roiZ(x), num2str(x),'fontsize',8,'fontname','Arial','horizontalAlignment','center')...
            ,1:length(sensorROI),'uni',false);
    else
    end
end


colormap(jmaColors('coolhotcortex'));
%colormap coolhot
%colormap gray
if showColorbar
    colorH = colorbar;
else
    colorH = NaN;
end
if ~isempty(colorbarLimits)
    caxis(colorbarLimits);
end
end