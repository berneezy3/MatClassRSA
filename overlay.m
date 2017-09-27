figure;
h = imagesc(rand(7,7));
axh = gca;
figh = gcf;
xticks = get(gca,'xtick');
yticks = get(gca,'ytick');
pos = get(axh,'position'); % position of current axes in parent figure

pic = imread('coins.png');
x = pos(1);
y = pos(2);
dlta = (pos(3)-pos(1)) / length(xticks); % square size in units of parant figure

% create image label
lblAx = axes('parent',figh,'position',[x+dlta/4,y-dlta/2,dlta/2,dlta/2]);
imagesc(pic,'parent',lblAx);
axis(lblAx,'off')
%%

lblAx = axes('parent',figh,'position',[pos(1)+pos(3),y-dlta/2,dlta/2,dlta/2]);
imagesc(pic,'parent',lblAx);
axis(lblAx,'off')


%%

myImage = imread('coins.png');
set(handles.axes7,'Units','pixels');
resizePos = get(handles.axes7,'Position');
myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
axes(handles.axes7);
imshow(myImage);
set(handles.axes7,'Units','normalized');