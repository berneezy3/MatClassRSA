function  [img, fig] = plotMatrix(RDM, varargin)
%-------------------------------------------------------------------
% [img,fig] = Visualization.plotMatrix(matrix, varargin)
% ------------------------------------------------
%
% This function plots a matrix.  The matrix can either be a
% representational dissimilarity matrix (RDM) computed by the functions in 
% +RDM_Computation, or a confusion matrix or pairwise accuracy matrix 
% output from the functions in +Classification.  
%
% REQUIRED INPUTS:
%   - RDM: A matrix, e.g., a confusion matrix, RDM/distance matrix.
%
% OPTIONAL NAME-VALUE INPUTS:
%   - 'ranktype': specification for whether to convert matrix values to 
%       percentile ranks (a common step when visualizing RDMs) or ranks
%       prior to plotting. Note that conversion of values to ranks or 
%       percentile ranks assumes a symmetric input matrix and operates only 
%       on values in the lower triangle of the matrix, not including the 
%       diagonal. If a non-symmetric matrix is input, a warning is printed 
%       and conversion proceeds using only lower-triangle values, returning 
%       a symmetric matrix.
%       --options--
%       'none' - perform no conversion of matrix values (default)
%       'rank' - convert matrix values to ranks
%       'percentrank' - convert matrix values to percentile ranks
%   - 'axisColors': a vector of colors, ordered by the order of labels in the 
%       confusion matrix.  If this argument is passed in, then square color
%       blocks will be used as the row/column labels.  Colors can be 
%       expressed as an RGB triplet, short name or long name, e.g. 
%       {'y' 'm' 'c' 'r'} or {'yellow' 'magenta' 'cyan' 'red'} or 
%       {[1 1 0] [1 0 1] [0 1 1] [1 0 0]}. See Matlab color 
%       specification documentation for more info: 
%           https://www.mathworks.com/help/matlab/ref/colorspec.html
%   - 'axisLabels': a matrix of alphanumeric labels, ordered by same order 
%       of 'colorMap' - This parameter can be used to call a default Matlab 
%       colormap, or one specified by the user, to change the overall look 
%       of the plot. For example, plotMatrix(RDM, 'colorMap', 'hsv')
%   - 'axisFontSize': Specify the font size of the axis labels.
%   - 'colorBar' - Choose whether to display colorbar or not (default 0)
%       --options--
%       0 - hide (default)
%       1 - show
%   - 'matrixLabels' -  Use this parameter to choose whether or not to display 
%       values for each square in the matrix.  Ignore parameter to turn off, 
%       enter any value to turn on.
%   - 'roundLabels' - Use this parameter to round matrix values to the
%       nearest whole number. Boolean. Default True.
%   - 'FontSize' - Set font size of matrix and axis labels. Default 15
%   - 'ticks' - Set number of ticks on the colorbar, Default 5
%   - 'textRotation' - Set rotation of text.  Default 0
%   - 'colorBlockSize' - This parameter determines the size of each color block icon.  
%       Default dyamically set as 5.
%   - 'colorMap' - Specify colormap. This parameter can be used to call a
%       default Matlab colormap, or one specified by the user, to change the
%       overall look of the plot. For example, plotMatrix(RDM, 'colorMap',
%       'hsv')
% 
% OUTPUTS:
%   - 'img': Handle of the plot (image) axis
%   - 'fig': Handle of the output figure
%
% MatClassRSA dependencies: Utils.getTickCoord(), Utils.rankDistances()

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

    % parse inputs
    ip = inputParser;
    ip.FunctionName = 'plotCM';
    ip.addRequired('matrix',@ismatrix);
    options = [1, 0];
    expectedRanktype = {'none', 'rank', 'percentrank'};
    defaultRanktype = 'none';
    
    ip.addParameter('ranktype', defaultRanktype,...
        @(x) any(validatestring(x, expectedRanktype)));
    ip.addParameter('axisColors', [], @(x) isvector(x)); 
    ip.addParameter('axisLabels', [], @(x) isvector(x));
    ip.addParameter('axisFontSize', 25, @(x) isnumeric(x));
    ip.addParameter('colormap', '');
    ip.addParameter('colorbar', '');
    ip.addParameter('matrixLabels', 0);
    ip.addParameter('roundLabels', 1);
    ip.addParameter('matrixLabelColor', 'black');
    ip.addParameter('FontSize', 15, @(x) isnumeric(x));
    ip.addParameter('ticks', 5, @(x) (isnumeric(x) && x>0));
    ip.addParameter('textRotation', 0, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('colorBlockSize', 5, @(x) assert(isnumeric(x), ...
        'colorBlockSize must be a numeric value'));
    parse(ip, RDM, varargin{:});
    
    
    % check for square matrix
    [r c] = size(RDM);
    if (r ~= c)
        error('Input matrix must be square matrix.')
    end
    
    % Rank distances
    RDM = Utils.rankDistances(RDM, ip.Results.ranktype);
    
    img = imagesc(RDM);
    fig = gcf;

    if ~isempty(ip.Results.colormap)
        colormap(ip.Results.colormap);
    end

    if (ip.Results.matrixLabels == 1)

        if (ip.Results.roundLabels == 1)
            % Round values to nearest whole number for display
            roundedVals = round(RDM);
        end
        
        % Create strings (integer-style)
        textStrings = arrayfun(@(x) sprintf('%d', x), roundedVals, 'UniformOutput', false);
        
        % Remove NaN labels (optional)
        textStrings(isnan(RDM)) = {''};
        
        % Create x and y coordinates for each element
        [x, y] = meshgrid(1:size(RDM, 2), 1:size(RDM, 1));
        
        % Plot the text labels
        text(x(:), y(:), textStrings(:), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', ip.Results.FontSize, ...
            'Color', ip.Results.matrixLabelColor);
    end
    
    if ip.Results.colorbar > 0
        c = colorbar;
        c.FontSize = ip.Results.FontSize;
        matMin = min(min(RDM));
        matMax = max(max(RDM));
        %truncMax = fix(matMax * 10^2)/10^2;
        inc = (matMax - matMin)/(ip.Results.ticks-1);
        %c.Ticks = str2num(sprintf('%.2f2 ', [[0:ip.Results.ticks-2] * inc + matMin  matMax]));
        switch lower(ip.Results.ranktype)
            case {'none', 'n'}
                c.Ticks = round(linspace(matMin, matMax, 3), 2);
            case {'rank', 'r'}
                t = sum(sum(tril(ones(size(RDM)), -1)));
                c.Limits = [0 t];
                c.Ticks = round(linspace(0, t, 3), 2);
            case {'percentrank', 'p'}
                c.Limits = [0 100];
                c.Ticks = 0:50:100; 
        c.FontWeight = 'bold';
    end
    

    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.axisLabels)
        labels = ip.Results.axisLabels;
    elseif isempty(ip.Results.axisLabels) && ~isempty(ip.Results.axisColors)
         labels = ip.Results.axisColors;
    else %no labels specified
%         set(gca,'xtick',[]);
%         set(gca,'ytick',[]);
        %return;
    end
    
    

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE:  DEFAULT LABELS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(ip.Results.axisColors) && isempty(ip.Results.axisLabels)
        disp('Plotting with default number labels...')
        set(gca,'xTickLabelRotation', ip.Results.textRotation);
        set(gca,'yTickLabelRotation', ip.Results.textRotation);

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE:  AXIS COLOR LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels)
        
        disp('Plotting with user defined colored labels...')
        
        set(gca,'xTick', [1:length(RDM)]);
        set(gca,'yTick',  [1:length(RDM)]);
        [xTickCoords yTickCoords] = Utils.getTickCoord;
        
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');
        numLabels = length(labels);
        bottomYCoord =  numLabels + .5;

        
        for i = 1:length(labels)
                label = labels(i);
                t = text(xTickCoords(i, 1), bottomYCoord, label, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'top');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.axisColors{i};
                t(1).FontSize = ip.Results.axisFontSize;
        end
        
        for i = 1:length(labels)
                label = labels(i);
                t = text(yTickCoords(i, 1), yTickCoords(i, 2), label, ...
                    'HorizontalAlignment', 'center');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.axisColors{i};
                t(1).FontSize = ip.Results.axisFontSize;

        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: AXIS LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels)
        disp('Plotting with user defined labels...')
        
        set(gca,'xTick', [1:length(RDM)]);
        set(gca,'yTick',  [1:length(RDM)]);
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');

        set(gca,'xTick', 1:length(ip.Results.axisLabels));
        set(gca,'yTick', 1:length(ip.Results.axisLabels));

        set(gca,'xTickLabel', ip.Results.axisLabels, 'FontSize', ip.Results.FontSize);
        set(gca,'yTickLabel', ip.Results.axisLabels, 'FontSize', ip.Results.FontSize);
        set(gca,'xTickLabelRotation', ip.Results.textRotation);
        set(gca,'yTickLabelRotation', ip.Results.textRotation);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.axisColors) && isempty(ip.Results.axisLabels)
        
                
        disp('Plotting with user defined colored blocks...')
        
          
        set(gca,'xTick', [1:length(RDM)]);
        set(gca,'yTick',  [1:length(RDM)]);
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');
        
        [xTickCoords yTickCoords] = Utils.getTickCoord;

        pos = get(gca,'position');
        leftMargin = pos(1);
        bottomMargin = pos(2);
        topMargin = pos(2) + pos(4);
        xdlta = (pos(3)) / (length(xTickCoords));
        ydlta = (pos(4)) / (length(yTickCoords));
        xinit = xdlta/2;
        yinit = ydlta/2;
        figPos = get(gcf, 'position');
        figWidth = figPos(3);
        figHeight = figPos(4);
        
        for i = 1:length(labels)
            
            % plot x axis labels
            lblAx = axes('parent',gcf,'position', ...
                [leftMargin + xinit + xdlta * (i-1) - ip.Results.colorBlockSize/2/figWidth ...
                ,bottomMargin-ip.Results.colorBlockSize/figHeight, ...
                ip.Results.colorBlockSize/figWidth, ip.Results.colorBlockSize/figHeight]);
            rectangle('FaceColor', labels{i});
            axis(lblAx,'off');
            % plot y axis labels
            lblAx = axes('parent',gcf,'position', ...
                [leftMargin - ip.Results.colorBlockSize/figWidth ...
                ,topMargin - yinit - ydlta * (i-1) - ip.Results.colorBlockSize/2/figHeight, ...
                ip.Results.colorBlockSize/figWidth, ip.Results.colorBlockSize/figHeight]);
            rectangle('FaceColor', labels{i});
            axis(lblAx,'off');

        end
    end
        
    xlh = xlabel('Predicted Label');
    xlh.Position(2) = xlh.Position(2) + .35;  
    ylh = ylabel('Actual Label');
    ylh.Position(1) = ylh.Position(1) - .45;  


end