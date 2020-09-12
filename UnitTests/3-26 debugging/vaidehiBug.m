

X1 = rand(128, 10 ,4900);

Y1 = zeros(500, 1);

Y1(1:100) = 1;
Y1(101:200) = 2;
Y1(201:300) = 3;
Y1(301:400) = 4;
Y1(401:500) = 5;

classifyEEG(X1, Y1, 'classify', 'LDA', 'PCA', .99)


%%

X2 = rand(128, 490, 500);

Y = zeros(500, 1);

Y(1:100) = 1;
Y(101:200) = 2;
Y(201:300) = 3;
Y(301:400) = 4;
Y(401:500) = 5;

classifyEEG(X2, Y, 'classify', 'LDA', 'PCA', .99)

%%
X2_sub = X2(:, 1:50, :);
classifyEEG(X2_sub, Y, 'classify', 'LDA', 'PCA', .99);


%%

load ../allData.mat

%% NO cleaning

[CM ACC] = classifyEEG(Finalmat(:, 1:300, :), label, 'classify', 'LDA', 'PCAinFold', 0)

%%

X = cube2trRows(Finalmat(:, 1:50, :));
cleanX = X(any(X~=0,2), :);
cleanY = label(any(X~=0,2));
zeroIndx = find(any(X~=0,2)==0);
[CM_clean2 ACC_clean2] = classifyEEG(cleanX, cleanY, 'classify', 'LDA', 'PCAinFold', 0, 'randomseed', 'default');

%%

X = cube2trRows(Finalmat(:, 1:50, :));
cleanX = X(any(X~=0,2), :);
cleanY = label(any(X~=0,2));
zeroIndx = find(any(X~=0,2)==0);
[CM_clean ACC_clean] = classifyEEG(cleanX, cleanY, 'classify', 'LDA', 'PCAinFold', 0, 'randomseed', 'default');

