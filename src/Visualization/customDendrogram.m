function y = customDendrogram(distMat, varargin)

    ip = inputParser;
    ip.FunctionName = 'customDendrogram';
    ip.addRequired('distMat',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});
    
    tree = linkage(distMat);
    [r c] = size(tree);
    d = dendrogram(tree, 0);

    %set(gca,'xtick',[]);
    if length(ip.Results.nodeLabels) >= 1
        xticklabels(ip.Results.nodeLabels);
    else
        set(gca,'xtick',[]);
    end
    
    set(gca,'FontSize',30);
    set(gca,'ytick',[]);
    axis off;
    set(gcf,'color',[1 1 1]);
    
    F = getframe(gcf);

    dendrogramImg = im2double(F.cdata);

    imagesc(dendrogramImg);
    addpath(ip.Results.iconPath);
    
    %check that either labels or iconPath has the same amount as nodeColors
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        
        labels = ip.Results.nodeLabels;
        
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        
        labels = dir(ip.Results.iconPath);
        labels = labels(4:length(labels));
        
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        return;
    end

    %iconPath(1).name
    
%     for i = 1:r+1
%         split = (1449-208)/(r+2);
%         plot(208 + split * i, 950, 'g.', 'MarkerSize', 20);
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) & ~isempty(ip.Results.nodeLabels)

        for i = 1:length(labels)

            split = (1449-205)/(r+2);
            centerX =  208 + split * i;
            centerY =  950;
            width = 40;
            height = 40;
            if i <= length(ip.Results.nodeColors)

              %dendrogramImg(centerX-width/2, centerY-height, :) = thisIcon;
    %           rectangle('Position',[centerX-width/2, centerY-height, width, height], ...
    %              'FaceColor',[1 0 0],'EdgeColor', ip.Results.nodeColors(i),'LineWidth',1)
                label = labels(i)
                t = text(centerX-width/3, centerY-height, label);
                t.Color = ip.Results.nodeColors(i);
                t(1).FontSize = 14;
            else
    %           %dendrogramImg(centerX-width/2, centerY-height, :) = thisIcon;
    %           rectangle('Position',[centerX-width/2, centerY-height, width, height], ...
    %                'FaceColor',[1 0 0],'LineWidth',4)
            end
            
            
            
            
        end
        
        
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR AND IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) & ~isempty(ip.Results.iconPath)
        
        for i = 1:length(labels)
            disp(i)
            [thisIcon map] = imread([labels(i).name]);
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            
            if ~isempty(map)
                disp('converting to RGB')
                disp(map)
                thisIcon = ind2rgb(thisIcon, map);
            else
                thisIcon = thisIcon/255;
            end
            
            % Resize to 40*40 square
            if height > width
                thisIcon = imresize(thisIcon, [40 NaN]);
            else
                thisIcon = imresize(thisIcon, [NaN 40]);
            end

            % Add 3rd(color) dimension if there is none
            disp(size(thisIcon))
            if length(size(thisIcon)) == 2
                disp('KSJDKAJSNDKA')
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);

            end
            
            split = round((1449-208)/(r+2));
            centerX =  208 + split * i;
            centerY =  950;
            width = 40;
            height = 40;
            cWidth = 58;
            cHeight = 58;
            if i <= length(ip.Results.nodeColors)
                rect = rectangle('Position',[centerX-cWidth/2, centerY-cHeight, cWidth, cHeight], ...
                'FaceColor', [0 1 0]);
                %dendrogramImg(centerY-cHeight:centerY-1, centerX-cWidth/2:centerX+cWidth/2-1, 1:3) = rect;
                x = [centerX-cWidth/2, centerX-cWidth/2, centerX+cWidth/2, centerX+cWidth/2];
                y = [centerY-cHeight, centerY, centerY-cHeight, centerY];
                patch(x,y, 'red');
                %dendrogramImg(centerY-height:centerY-1, centerX-width/2:centerX+width/2-1, 1:3) = thisIcon;
                image(dendrogramImg);
                label = labels(i);
            else
    %           %dendrogramImg(centerX-width/2, centerY-height, :) = thisIcon;
    %           rectangle('Position',[centerX-width/2, centerY-height, width, height], ...
    %                'FaceColor',[1 0 0],'LineWidth',4)
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) and isempty(ip.Results.iconPath) ...
            and isempty(ip.Results.nodeLabels)
        
         
    end
     
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);

    hold on
     
end

%helper function to customDendrogram
function y = colorSquare(original, xCorner, yCorner, width, height)
    
    

end

