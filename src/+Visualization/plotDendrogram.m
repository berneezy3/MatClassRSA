function fig = plotDendrogram(RDM, varargin)
%-------------------------------------------------------------------
% fig = Visualization.plotDendrogram(RDM, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017, Ray - Edit 2025
%
% Given a distance matrix as input, this function plots a dendrogram.  
% Optional name-value pair arugments are described below.
%
% REQUIRED INPUTS:
%   RDM: A distance matrix.  Diagonals must be 0, and the matrix must be
%   	symmetrical along the diagonal.
%
% OPTIONAL NAME-VALUE INPUTS:
%   'nodeColors': a vector of colors, whose order corresponds to the order 
%       of labels in the confusion matrix.  For example, if user inputs: 
%        ['yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'],  
%       then class 1 would be yellow, class 2 would be magenta... class 8 
%       would be black.  Each color can be expressed as an RGB triplet 
%       ([1 1 0]), short name ('y') or long name ('yellow').  See Matlab 
%       color specification documentation for more info: 
%           https://www.mathworks.com/help/matlab/ref/colorspec.html
%   'nodeLabels': A matrix of alphanumeric labels, whose order corresponds 
%       to the labels in the confusion matrix. e.g. ['cat' 'dog' 'fish']
%   'fontSize': A number to specify the font size of labels.
%   'orientation' - This parameter lets the user specify which direction 
%       to plot the dendrogram leaves.
%       --options--
%       'down' (default) 
%       'up' 
%       'left'
%       'right'
%   'reorder' - Specify order of classes in the dendrogram.  Must be passed
%       in as a length N vector, N being the number of classes in RDM.  
%       Also, vector should contain values 1:N. Note that custom orderings
%       may disrupt the structure of the dendrogram.
%   'yLim' - Set range of the Y-axis.  Pass in as an array of length 2, 
%       e.g. [yMin yMax].
%   'textRotation' - Amount in degrees to rotate the text labels.  For 
%       visibility purposes.  Default 0.
%   'lineWidth' - Use this parameter to set the width of the lines in the 
%       dendrogram.  Default 2.
%   'lineColor' - Use this parameter to set the color of the lines in the
%       dendrogram.  Similar to 'nodeColors', we can either pass in color 
%       abbreviations, full-length color names, or RGB color triplets.  
%       Default 'black'.
%   'colorBlockSize' - This parameter determines the size of each color block icon.  
%       Default dyamically set as 5.
%
% OUTPUTS:
%   'fig': figure corresponding to output plot

% Notes:
%   - linkage order - inorder w/ crossing, best order w/o crossing, dist
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
%
% MatClassRSA dependencies: Utils.getImageFiles(), Utils.TickCoord()
    

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
    ip.addParameter('colorBlockSize', 5, @(x) assert(isnumeric(x), ...
        'colorBlockSize must be a numeric value'));
    
    parse(ip, RDM,varargin{:});
    
    % extract RDM lower triangle
    RDM = Utils.processRDM(RDM);
    tree = linkage(RDM, ip.Results.distMethod);
    [r c] = size(tree);
    tree(:,3) = tree(:,3) / max(tree(:,3)); % Normalization step
    
    
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
    
    fig = gcf;
    
    % Set dendrogram Y axis height
    if ~isempty(ip.Results.yLim)
        ylim(ip.Results.yLim);
    end
    
    %%%%%%%%%%%%%%%%%%%%
    % CONVERT TO MATRIX
    %%%%%%%%%%%%%%%%%%%%    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        labels = ip.Results.nodeLabels;
    %color labels
    elseif isempty(ip.Results.nodeLabels) && ~isempty(ip.Results.nodeColors)
         labels = ip.Results.nodeColors;
    else %no labels specified
%         set(gca,'xtick',[]);
%         set(gca,'ytick',[]);
%         hold on;
%         return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
        disp('Plotting with user defined colored labels...')
        xTickCoords = Utils.getTickCoord;
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
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.nodeLabels)
        disp('Plotting with user defined colored blocks...')
        
        set(gca,'xTickLabel', '');
        xTickCoords = Utils.getTickCoord;
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
                    ip.Results.colorBlockSize/2/figWidth,y-ip.Results.colorBlockSize/figHeight, ...
                    ip.Results.colorBlockSize/figWidth, ip.Results.colorBlockSize/figHeight]);
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

function y = isPosInt(x)

    if floor(x)==x && x>0
        y = 1;
    else
        y = 0;
    end
    

end
