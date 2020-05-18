function fig = plotDendrogram(RDM, varargin)
%-------------------------------------------------------------------
% plotDendrogram(RDM, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function creates a dendrogram plot with the distance matrix
% passed in.
%
% INPUT ARGS (REQUIRED):
%   RDM: A distance matrix.  Diagonals must be 0, and must be
%               symmetrical along the diagonal
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'nodeColors': a vector of colors, ordered by the order of labels in the 
%       confusion matrix e.g. {?y? ?m? ?c? ?r?} or {?yellow? ?magenta? ?cyan? ?red?}
%       or {?[1 1 0]? ?[1 0 1]? ?[0 1 1]? ?[1 0 0]?}
%       Can be used in conjuction with 'nodeLabels'.
%   'nodeLabels': a matrix of alphanumeric labels, ordered by same order of
%       labels in the confusion matrix e.g. ['cat' 'dog' 'fish'].  Can be
%       used in conjunction with 'nodeColors'.
%   'iconPath': a directory containing imaAges used to label, in which the
%       image files must be ordered in the same order as the 
%       labels of the confusion matrix
%   'fontSize': a number to specify the size of fonts when plotting colored
%   labels.
%   'orientation' - Dendrogram orientation.  This parameter lets the user 
%       specify which direction to point the dendrogram (orientation defined 
%       here as the side that contains the dendrogram leaves).
%       --options--
%       'down' (default) 
%       'up' 
%       'left'
%       'right'
%   'reorder' - Specify order of classes in the dendrogram.  Must pass in
%       as a length N vector, N being the number of classes in RDM.  Also,
%       vector should contain values 1:N. 
%   'yLim' - Set range of the Y-axis.  Pass in as an array of length 2, 
%       [yMin yMax].
%   'textRotation' - Set this parameter to an  amount in degrees to rotate 
%       the text.  Default 0.
%   'lineWidth' - Line width  Use this parameter to set the width of the 
%       lines in the dendrogram.  Default 2.
%   'lineColor' - Line color  Use this parameter to set the color of the 
%       lines in the dendrogram.  Similar to 'nodeColors', we can either 
%       pass in color abbreviations, full-length color names, or RGB color triplets.
%       Default 'black'.
%   'iconSize' - if parameter 'iconPath' is passed in, then this parameter
%       will determine the size of each image icon.  Default 40.
%
% OUTPUT ARGS:
%   'img' - figure corresponding to output plot

% Notes:
%   - linkage order - inorder w/crossing, best order w/o crossing, dist
%   order
%   - flip horizontal
%   - make sure the side thin
%   - make sure the dendrogram is in the correct order, not the order of
%   the dist matrix

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
    

    expectedDistMethod = {'average', 'centroid', 'complete', 'median', 'single', ...
        'ward', 'weighted'};
    expectedOrientation = {'up', 'down', 'left', 'right'};

    ip = inputParser;
    ip.FunctionName = 'plotDendrogram';
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('distMethod', 'average', @(x) any(validatestring(x,  ...
        expectedDistMethod)));
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('fontSize', 25, @(x) isnumeric(x));
    ip.addParameter('iconPath', '');
    ip.addParameter('orientation', 'down', @(x) any(validatestring(x, ...
        expectedOrientation)));
    ip.addParameter('reorder', [], @(x) assert(length(x) == length(RDM)));
    %ip.addParameter('maxLeafs', 0, @(x) assert(x >= 0 && isnumeric(x)) );
%     ip.addParameter('plotHeight', '', @(x) assert(isnumeric(x)));
    ip.addParameter('yLim', '', @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'ylim must be length 2 vector'));
    ip.addParameter('textRotation', 0, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('lineWidth', 2, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('lineColor', 'black');
    ip.addParameter('iconSize', 40);
    
    parse(ip, RDM,varargin{:});
    
    RDMmod = RDM(tril(true(size(RDM)),-1))';
    tree = linkage(RDMmod, ip.Results.distMethod);
    [r c] = size(tree);
    
    
    if (~isempty(ip.Results.reorder))
        [d T P] = dendrogram(tree, 0, 'reorder', ip.Results.reorder);
    else
        % all leaf nodes
        [d T P] = dendrogram(tree, 0);
    end
    img = gcf;
    
    set(d ,'LineWidth',  ip.Results.lineWidth, 'Color', ip.Results.lineColor);
    %set(gca,'xtick',[]);
    if length(ip.Results.nodeLabels) >= 1
        xticklabels(ip.Results.nodeLabels);
    end
    

    set(gca,'FontSize',ip.Results.fontSize);
    %set(gca,'xtick',[]);
    set(gcf,'color',[1 1 1]);
    
    % Set dendrogram Y axis height
    if ~isempty(ip.Results.yLim)
        ylim(ip.Results.yLim);
    end
    
    %%%%%%%%%%%%%%%%%%%%
    % CONVERT TO MATRIX
    %%%%%%%%%%%%%%%%%%%%
%     F = getframe(gcf);
%     dendrogramImg = im2double(F.cdata);
    
    %imagesc(dendrogramImg);
    addpath(ip.Results.iconPath);
    
    %check that either labels or iconPath has the same amount as nodeColors
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        labels = ip.Results.nodeLabels;
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        labels = getImageFiles(ip.Results.iconPath);
    %color labels
    elseif isempty(ip.Results.nodeLabels) && isempty(ip.Results.iconPath) && ~isempty(ip.Results.nodeColors)
         labels = ip.Results.nodeColors;
    else %no labels specified
%         set(gca,'xtick',[]);
%         set(gca,'ytick',[]);
%         hold on;
%         return;
    end

    %iconPath(1).name


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
        disp('Plotting with user defined colored labels...')
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');

        for i = 1:length(labels)
            if i <= length(ip.Results.nodeColors)
                label = labels(P(i));
                t = text(xTickCoords(i, 1), xTickCoords(i, 2), label, ...
                    'HorizontalAlignment', 'center');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.nodeColors{P(i)};
                t(1).FontSize = ip.Results.fontSize;
            else

            end

            
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) &&  ~isempty(ip.Results.nodeLabels)

        disp('Plotting with user defined labels...')
        set(gca,'xTickLabel', '');


%         labels = NaN{1,length(RDM)};
%         for i = 1:length(RDM)
%             labels(i) = ip.Results.nodeLabels{P(i)};
%         end
        
        set(gca,'xTickLabel', ip.Results.nodeLabels);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeLabels) && ~isempty(ip.Results.iconPath)
        
         disp('Plotting with user specified directory of image icons...')
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');
        pos = get(gca,'position');
        x = pos(1);
        y = pos(2);
        dlta = (pos(3)) / (length(xTickCoords) + 1);
        figPos = get(gcf, 'position');
        figWidth = figPos(3);
        figHeight = figPos(4);
        
        for i = 1:length(labels)
            [thisIcon map] = imread([char(labels(i))]);
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            
            if ~isempty(map)
                disp('converting to RGB')
                %disp(map);
                thisIcon = ind2rgb(thisIcon, map);
            end
            
            % Resize to 40*40 square
%             if height > width
%                 thisIcon = imresize(thisIcon, [ip.Results.iconSize NaN]);
%             else
%                 thisIcon = imresize(thisIcon, [NaN ip.Results.iconSize]);
%             end

            % Add 3rd(color) dimension if there is none
            if length(size(thisIcon)) == 2
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
            end

            if i <= length(labels)
                lblAx = axes('parent',gcf,'position',[pos(1)+dlta*i - ...
                    ip.Results.iconSize/2/figWidth,y-ip.Results.iconSize/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                imagesc(thisIcon,'parent',lblAx);
                axis(lblAx,'off');
            else
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        disp('Plotting with user defined colored blocks...')
        
        set(gca,'xTickLabel', '');
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');
        pos = get(gca,'position');
        x = pos(1);
        y = pos(2);
        dlta = (pos(3)) / (length(xTickCoords) + 1);
        
        figPos = get(gcf, 'position');
        figWidth = figPos(3);
        figHeight = figPos(4);
        
        for i = 1:length(labels)

            if i <= length(labels)
                lblAx = axes('parent',gcf,'position',[pos(1)+dlta*i - ...
                    ip.Results.iconSize/2/figWidth,y-ip.Results.iconSize/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                rectangle('FaceColor', labels{i});
                axis(lblAx,'off');
            else
            end
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: NONE (Default number labels)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        
        disp('Plotting with default number labels...')
        % Do NOTHING

        
        
    end
    
    hold on;
     
end

%helper function to customDendrogram
function y = colorSquare(original, xCorner, yCorner, width, height)
    
    

end

function y = isPosInt(x)

    if floor(x)==x && x>0
        y = 1;
    else
        y = 0;
    end
    

end
