load fisheriris
X = meas;
Y = species;
rng(1); % For reproducibility

t = templateSVM('Standardize',true, 'KernelFunction','rbf')

%%

Mdl = fitcecoc(X,Y,'Learners',t...
    );
%    ,'ClassNames',{'setosa','versicolor','virginica'}, 'Coding', 'onevsall');

CVMdl = crossval(Mdl);

genError = kfoldLoss(CVMdl);

%[label,score] = resubPredict(Mdl,'Verbose',1);


[label,score] = predict(Mdl, [5.1 3.5 1.4 0.2;  5.9 3 5.1 1.8]);

%%

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%%

[ecocC] = classifyCrossValidate(X_3D, ...
    categoryLabels, "PCAinFold", 0, 'classifier', 'SVM2');

%%

[libsvmC] = classifyCrossValidate(X_3D, ...
    categoryLabels, "PCAinFold", 0, 'classifier', 'SVM');