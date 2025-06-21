function fig = plotMDS(RDM, varargin)
%-------------------------------------------------------------------
%  fig = Visualization.plotMDS(RDM, 'nodeColors', 'nodeLabels')
% ------------------------------------------------
%
% This function creates a MDS plot with the distance matrix
% passed in.
%
% REQUIRED INPUTS:
% - RDM: A distance matrix.  Diagonals must be 0, and must be
%               symmetrical along the diagonal
%
% OPTIONAL NAME-VALUE INPUTS:
%   'nodeColors': a vector of colors, whose order corresponds to the order 
%       of labels in the confusion matrix.  For example, if user inputs: 
%        ['yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'],  
%       then class 1 would be yellow, class 2 would be magenta... class 8 
%       would be black.  Colors can be expressed as an RGB triplet 
%       ([1 1 0]), short name ('y') or long name ('yellow').  See Matlab 
%       color specification documentation for more info: 
%           https://www.mathworks.com/help/matlab/ref/colorspec.html
%   'nodeLabels': A matrix of alphanumeric labels, whose order corresponds 
%       to the labels in the confusion matrix. e.g. ['cat' 'dog' 'fish']
%   'dimensions': Choose which MDS dimensions to display (default [1 2]).
%   'xLim': Set range of the X-axis with array of length 2, [xMin xMax].
%   'yLim': Set range of the Y-axis with an array of length 2, [yMin yMax].
%   'classical':  choose between classical (1) and non-classical (0) mdscaling.
%       Default is classical (1). More info can be found here: 
%       https://www.mathworks.com/help/stats/cmdscale.html
%
% OUTPUTS:
%    fig: figure corresponding to output plot
%
% MatClassRSA dependencies: Utils.processRDM()

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

    RDM = Utils.processRDM(RDM);
    
    if length(find(RDM<0)) > 0
        warning('Distance less than 0 detected, converting negative distances to 0');
        RDM(RDM<0) = 0;
    end

    ip = inputParser;
    ip.FunctionName = 'plotMDS';
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) assert(isvector(x))); 
    ip.addParameter('nodeLabels', [], @(x) assert(isvector(x)));
    ip.addParameter('classical', 1, @(x) assert(isnumeric(x)));

    % which dimensions of MDS to plot
    ip.addParameter('dimensions', [1 2], @(x) assert(isvector(x) && ...
        isequal(size(x), [2 1]) || isequal(size(x), [1 2]), ...
        'dimensions must be vector of length 2'));
    ip.addParameter('xLim', [], @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'xlim must be length 2 vector'));
    ip.addParameter('yLim', [], @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'ylim must be length 2 vector'));

    parse(ip, RDM,varargin{:});
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        
        labels = ip.Results.nodeLabels;
        
    elseif isempty(ip.Results.nodeLabels) && ~isempty(ip.Results.nodeColors)
        
        labels = ip.Results.nodeColors;
        
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        s = length(RDM);
        labels = [1:s];
    end
    
    
    if (ip.Results.classical ~=0)
        [Y eigs] = cmdscale(RDM);
    else
        [Y,stress] = mdscale(RDM, length(RDM));
    end
    
    % generate figure and image for output
    fig = gcf;
    %img = imagesc(RDM);
        
    [r c] = size(Y);
    set(gca, 'YAxisLocation', 'origin');
    set(gca, 'XAxisLocation', 'origin');
    
    % set dimensions
    xDim = ip.Results.dimensions(1);
    yDim = ip.Results.dimensions(2);
    if or((xDim<1 | xDim>r), (yDim<1 | yDim>r))
        error('Both xDim and yDim must be between 1 and length(RDM)');
    end
    
    % Set plot axis limits
    xMax = max(Y(:,xDim));
    xMin = min(Y(:,xDim));
    xMax = xMax + (xMax-xMin)/10;
    xMin = xMin - (xMax-xMin)/10;
    
    yMax = max(Y(:,yDim));
    yMin = min(Y(:,yDim));
    yMax = yMax + (yMax-yMin)/10;
    yMin = yMin - (yMax-yMin)/10;
    
    if isempty(ip.Results.xLim)
        xlim([xMin xMax]);
    else
        xlim(ip.Results.xLim);
    end
    if isempty(ip.Results.yLim)
        ylim([yMin yMax]);
    else
        ylim(ip.Results.yLim);
    end
     % x-axis, y-axis label
    xlabel(['Dimension ' num2str(ip.Results.dimensions(1))], 'FontWeight', 'bold');
    ylabel(['Dimension ' num2str(ip.Results.dimensions(2))], 'FontWeight', 'bold'); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: DEFAULT LABELS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(ip.Results.nodeColors) && isempty(ip.Results.nodeLabels)
        disp('CASE: DEFAULT LABELS')
        labels = [1:length(RDM)];
        for i = 1:length(RDM)
            text(Y(i,xDim), Y(i,yDim), num2str(labels(i)), ...
                'FontSize', 30);
        end
        
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
    
        disp('CASE: COLOR AND NODE')
        for i = 1:r

          % artificial method of setting siz
%             plot( Y(i,1) ,Y(i,2) , 's', 'MarkerSize', 15, 'LineWidth', 2, ....
%                 'MarkerEdgeColor', 'k');
            text( Y(i,xDim), Y(i,yDim), char(ip.Results.nodeLabels(i)), ...
                'Color', ip.Results.nodeColors{i}, ...
                'FontWeight', 'bold', 'FontSize', 30 ...
            );
            hold on  
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
        disp('CASE: NODE')
        for i = 1:length(RDM)
            text(Y(i,xDim), Y(i,yDim), ip.Results.nodeLabels(i), ...
                'FontSize', 30);
        end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.nodeLabels)
        
        for i = 1:r
            plot( Y(i,xDim) ,Y(i,yDim) , 'o', 'MarkerSize', 15, 'LineWidth', 4, ...
                'MarkerEdgeColor', ip.Results.nodeColors{i}, ...
                'MarkerFaceColor', ip.Results.nodeColors{i});
        end
            xlim([xMin xMax]);
            ylim([yMin yMax]);
    end
    
    hold on;
    
    

    
end


    
    