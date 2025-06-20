function  fig = plotMST(RDM, varargin)
%-------------------------------------------------------------------
%  fig = Visualization.plotMST(RDM, varargin)
% ------------------------------------------------
%
% This function, given a distance matrix input, plots a minimum spanning
% tree(MST).  Optional name-value pair arugments are described below.
%
% REQUIRED INPUTS:
% - RDM: A distance matrix.  Diagonals must be 0, and must be symmetrical 
%       along the diagonal.
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
%   'edgeLabelSize': Set the size of the MST edge labels.  Default is 15.
%   'nodeLabelSize': Set the size of node labels.  Default is 15.
%   'nodeLabelRotation': Set the angle of the node label.
%   'lineWidth': MST line color.  Default is 2
%   'lineColor': MST line color.  Default is [.5 .5 .5].  Colors can be 
%       expressed as an RGB triplet ([1 1 0]), short name ('y') or long 
%       name ('yellow').
%
% OUTPUTS:
%  fig: Figure corresponding to output plot
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

    % parse inputs
    ip = inputParser;
    ip.FunctionName = 'plotMST';
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('edgeLabelSize', 15, @(x) isnumeric(x));
    ip.addParameter('nodeLabelSize', 15, @(x) isnumeric(x));
    ip.addParameter('nodeLabelRotation', 0, @(x) isnumeric(x));
    ip.addParameter('lineWidth', 2, @(x) assert(isnumeric(x)));
    ip.addParameter('lineColor', [.5 .5 .5]);

    parse(ip, RDM, varargin{:});
    

    % set up the nodes and connections between
    RDM = Utils.processRDM(RDM);
    [r c] = size(RDM);
    numEdges = ((r-1) + (r-1)^2)/2;
    numNodes = r;
    sourceNodes = NaN(numEdges, 1);
    destNodes = NaN(numEdges, 1);
    weights = NaN(numEdges, 1);
    index = numEdges;
    for i = 1:numNodes-1
        for j = 1:i
            sourceNodes(index) = numNodes - i;
            destNodes(index) = numNodes + 1 - j;
            weights(index) = RDM(sourceNodes(index), destNodes(index));
            index = index - 1;
        end
    end

    G = graph(sourceNodes, destNodes,weights);
    
    %p = plot(G,'EdgeLabel',G.Edges.Weight);
    [T,pred] = minspantree(G);
    P = plot(T);

    % generate figure and image for output
    fig = gcf;
    %img = imagesc(RDM);
    highlight(P, T, 'LineWidth',  ip.Results.lineWidth, 'EdgeColor', ip.Results.lineColor);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
    
        disp('CASE: COLOR AND NODE')
        plt = MSTplothelper(sourceNodes, destNodes, weights, ...
            ip.Results.nodeLabels, ip);
        MSTcolorhelper(ip.Results.nodeLabels, ip.Results.nodeColors, plt);
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
        
        disp('CASE: NODE')
        MSTplothelper(sourceNodes, destNodes, weights, ip.Results.nodeLabels, ip);
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.nodeLabels)
        
        disp('CASE: COLOR AND NODE')
        
        nodeLabels = {};
        for i = 1:length(RDM)
            nodeLabels = [nodeLabels  num2str(i)];
        end
%         nodeLabels = [1:length(RDM)];

        plt = MSTplothelper(sourceNodes, destNodes, weights, ...
            nodeLabels, ip);
        MSTcolorhelper(nodeLabels, ip.Results.nodeColors, plt);
        
        
    end
    
    
end

function plt = MSTplothelper(sourceNodes, destNodes, weights, nodeLabels, ip)
%--------------------------
% helper function to plot the MST 
% 
% args - 
%   sourceNodes - source nodes for the connections
%   destNodes - destination nodes for the connections
%   weights - the weights of each connection
%   nodeLabels - actual label of each node, as opposed to number ID
        sourceLabels = {};
        destLabels = {};
        for i = 1:length(sourceNodes)
            sourceLabels  = [sourceLabels nodeLabels(sourceNodes(i))];
            destLabels = [destLabels nodeLabels(destNodes(i))];
        end
        
        G = graph(sourceLabels, destLabels, weights);
        [T,pred] = minspantree(G);
        plt = plot(T, 'LineWidth',  ip.Results.lineWidth, 'EdgeColor', ip.Results.lineColor);
        
        nl = plt.NodeLabel;
        plt.NodeLabel = '';
        xd = get(plt, 'XData');
        yd = get(plt, 'YData');
        
        text(xd, yd, nl,  'FontSize',  ip.Results.nodeLabelSize,...
            'HorizontalAlignment','left', 'VerticalAlignment','top', ...
            'Rotation', ip.Results.nodeLabelRotation, ...
            'FontSize', ip.Results.nodeLabelSize);
        
        % make table of edges
        [edgeR edgeC] = size(T.Edges.EndNodes);
        edgeCoord = NaN(edgeR, edgeC);
        format shortg;
        T.Edges.Weight = round(T.Edges.Weight, 3);

        for i = 1:edgeR
            startNode = findNodeWithLabel(nl, T.Edges.EndNodes(i,1));
            endNode = findNodeWithLabel(nl, T.Edges.EndNodes(i,2));
            edgeCoord(i,1) = (xd(startNode) + xd(endNode))/2;
            edgeCoord(i,2) = (yd(startNode) + yd(endNode))/2;
            ang = findAngle(xd(startNode), yd(startNode), xd(endNode), yd(endNode));
            text((xd(startNode) + xd(endNode))/2 ,(yd(startNode) + yd(endNode))/2, ...
                 num2str(T.Edges.Weight(i)), 'HorizontalAlignment','center', ...
                 'Rotation', ang, 'FontSize', ip.Results.edgeLabelSize, ...
                 'VerticalAlignment','top');
        end
        format;
        %make table containing coords for edges

        edgeCoord = NaN(edgeR, edgeC);

end


function plt = MSTimagehelper(sourceNodes, destNodes, weights, nodeLabels, ip)
%--------------------------
% helper function to plot the MST 
% 
% args - 
%   sourceNodes - source nodes for the connections
%   destNodes - destination nodes for the connections
%   weights - the weights of each connection
%   nodeLabels - actual label of each node, as opposed to number ID
        sourceLabels = {};
        destLabels = {};
        for i = 1:length(sourceNodes)
            sourceLabels  = [sourceLabels nodeLabels(sourceNodes(i))];
            destLabels = [destLabels nodeLabels(destNodes(i))];
        end
        
        G = graph(sourceLabels, destLabels, weights);
        [T,pred] = minspantree(G);
        plt = plot(T, 'LineWidth',  ip.Results.lineWidth, 'EdgeColor', ip.Results.lineColor);
        
        nl = plt.NodeLabel;
        plt.NodeLabel = '';
        xd = get(plt, 'XData');
        yd = get(plt, 'YData');
        
        yl = ylim;
        xl = xlim;
        
        pos = get(gca,'position');
        
%         plotHeight = (yl(2) - yl(1))/12;
%         plotLength = (xl(2) - xl(1))/12;
        
        plotHeight = (pos(3))/12;
        plotLength = (pos(4))/12;
        
end



function MSTcolorhelper(nodeLabels, nodeColors, graph)
    for i = 1:length(nodeColors)
        highlight(graph, nodeLabels(i), 'NodeColor', nodeColors{i}, 'markerSize', 15);
    end
end

function y = findNodeWithLabel(labels, label)
    %y = find(not(cellfun('isempty',strfind(labels,label))));
    y = find(strcmp(labels,label));
    assert(length(y) == 1 , 'labels need to be unique');
end

function y = findAngle(x1, y1, x2, y2)
    v1 = [x1-x2, y1-y2];
    m = v1(2)/v1(1);
    y = atan(m) * 180 / pi;
    if rem(y,90) ~= 0
        if y > 0
            %y = 90 - y;
        else
            %y = 270- y;
        end
    elseif (y > 90 && y <= 270) | (y >= -270 && y < -90)
        y = y + 180;
    elseif  y == 90 
        y = y+180;
    end
end