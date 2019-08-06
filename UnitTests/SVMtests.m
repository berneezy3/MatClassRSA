train = [1 1 ; 1 -1; -1 1; -1 -1];
labels = [1 1 2 2];

mdl = fitcsvm( train, labels, 'KernelFunction','linear' );

%%
disp("pt 1 score: ")
pt1score = train(1,:) * mdl.Beta + mdl.Bias;
disp(pt1score)

disp("pt 1 dist to bound: ")
w =   sum(mdl.Beta' .* mdl.SupportVectors(1,:)) ;
absW = sqrt(sum(sum(w^2)));
%check if we should add or subtract mdl.Bias
pt1dist = abs(pt1score)/absW - mdl.Bias;
disp( pt1dist )
%%

disp("pt 2 score: ")
pt2score = train(2,:) * mdl.Beta + mdl.Bias;
disp(pt2score)

disp("pt 2 dist to bound: ")
w =  sum(mdl.Beta' .* mdl.SupportVectors(1,:)) ;
absW = sqrt(sum(sum(w^2)));
pt2dist = abs(pt2score)/absW - mdl.Bias;
disp( pt2dist )

%%
train = [0 1 ; 1 0; -1 0; 0 -1];
labels = [1 2 3 4];
Mdl = fitcecoc(train, labels,'Learners',t);





%%
load fisheriris
t = templateSVM('KernelFunction','gaussian')
Mdl = fitcecoc(meas,species,'Learners',t);
