function fig = plotDendrogram(RDM, varargin)
%-------------------------------------------------------------------
% fig = Visualization.plotDendrogram(RDM, varargin)
% ------------------------------------------------
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
%   'normalization' - If set to true, this parameter will scale the branch 
%       heights (distances) by the maximum distance in the set, such that 
%       the maximum displayed distance becomes 1. Default false.
%
% OUTPUTS:
%   'fig': figure corresponding to output plot
%
% MatClassRSA dependencies: Utils.getTickCoord(), Utils.processRDM()


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
    ip.addParameter('normalization', false, @(x) islogical(x) || ismember(x, [0 1]));
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
    
    % Normalization step
    if (ip.Results.normalization)
        tree(:,3) = tree(:,3) / max(tree(:,3));
    end
    
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
    else
        maxValue = max(tree(:,3));
        ylim([0, maxValue]);
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

        disp('Plotting with user defined labels...');
        
        xTickCoords = Utils.getTickCoord;
        set(gca,'xTickLabel', '');

        for i = 1:length(labels)
            if i <= length(ip.Results.nodeColors)
                label = labels(P(i));
                t = text(xTickCoords(i, 1), xTickCoords(i, 2), label, ...
                    'HorizontalAlignment', 'center');
                t.Rotation = ip.Results.textRotation;
                t.Color = 'k';
                t(1).FontSize = ip.Results.fontSize;
            else
            end   
        end
        set(gca,'xTickLabel', ip.Results.nodeLabels);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.nodeLabels)
        
        disp('Plotting with user defined colored blocks...')
        
        ax = gca;
        xTickCoords = Utils.getTickCoord;
        set(gca,'xTickLabel', '');
        xlimData    = get(ax, 'XLim');                 
        posAxes     = get(ax, 'Position'); 
        
        % Convert each tick from data‐space to normalized‐units:
        xNorm = posAxes(1) + ((xTickCoords - xlimData(1)) ./ diff(xlimData)) * posAxes(3);
    
        % 2) Grab figure size so that we can translate a color‐block size (in pixels)
        %    into normalized units:
        figPos = get(gcf, 'Position');  % [left bottom width height] in pixels
        figW = figPos(3);
        figH = figPos(4);
        
        % Desired block “height” (in pixels) below the axis:
        blockSize = ip.Results.colorBlockSize;  % assume this is in pixels

        % Convert that to normalized (vertical) units:
        blockHeightNorm = blockSize / figH;
        blockWidthNorm  = blockSize / figW;

        
       % 3) Clear any existing x‐tick labels (we are drawing colored bars instead)
         set(ax, 'XTickLabel', '');
    
        % 6) Draw one small colored axes + rectangle per tick
        nColors = numel(ip.Results.nodeColors);
        for i = 1:nColors
            xCenter = xNorm(i);
            yBottom = posAxes(2) - blockHeightNorm;  % just below the main axes

            % Create a tiny axes for the color block
            axColor = axes( ...
                'Parent', gcf, ...
                'Units', 'normalized', ...
                'Position', [ ...
                    xCenter - blockWidthNorm/2, ...  % left
                    yBottom,                       ...  % bottom
                    blockWidthNorm,                ...  % width
                    blockHeightNorm                  % height
                ] ...
            );

            % Fill it with the i‐th color
            rectangle( ...
                'Parent',   axColor, ...
                'Position', [0 0 1 1], ...
                'FaceColor', ip.Results.nodeColors{i}, ...
                'EdgeColor', 'none' ...
            );
            axis(axColor, 'off');
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
