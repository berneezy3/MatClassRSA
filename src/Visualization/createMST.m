function y = createMST(distMat, varargin)

    ip = inputParser;
    ip.FunctionName = 'createMST';
    ip.addRequired('distMat',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});
    

    %create undirected graph
    [r c] = size(distMat);
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
            weights(index) = distMat(sourceNodes(index), destNodes(index));
            index = index - 1;
        end
    end

%     disp(sourceNodes);
%     disp(destNodes);
%     disp(weights);
    
    G = graph(sourceNodes, destNodes,weights);
    disp(G);
    %p = plot(G,'EdgeLabel',G.Edges.Weight);
    [T,pred] = minspantree(G);
    disp(T.Edges);
    disp(T.Edges.Weight);
    plot(T, 'EdgeLabel', T.Edges.Weight)
    
    
    end
