load '../losorelli_500sweep_epoched.mat'
X_Sl_500 = X;
Y_Sl_500 = Y;

[X_SL_500_shuf,Y_SL_500_shuf] = shuffleData(X_Sl_500, Y_Sl_500);

%%

load '../losorelli_100sweep_epoched.mat'
X_Sl_100 = X;
Y_Sl_100 = Y;

[X_SL_100_shuf,Y_SL_100_shuf] = shuffleData(X_Sl_100, Y_Sl_100);

% [X_avg,Y_avg] = averageTrials(X_shuf, Y_shuf, 5);

%% Create vectors for storing results
SL = {};

SL.LDA_noAvg_noPCA = zeros(1,5);      
SL.LDA_noAvg_onePCA = zeros(1,5);  
SL.LDA_noAvg_foldPCA = zeros(1,5);  
SL.LDA_avg_noPCA = zeros(1,5);      
SL.LDA_avg_onePCA = zeros(1,5);    
SL.LDA_avg_foldPCA = zeros(1,5);    

SL.SVM_noAvg_noPCA = zeros(1,5);
SL.SVM_noAvg_onePCA = zeros(1,5);
SL.SVM_noAvg_foldPCA = zeros(1,5);
SL.SVM_avg_noPCA = zeros(1,5);      
SL.SVM_avg_onePCA = zeros(1,5);    
SL.SVM_avg_foldPCA = zeros(1,5);    

SL.RF_noAvg_noPCA = zeros(1,5);   
SL.RF_noAvg_onePCA = zeros(1,5);
SL.RF_noAvg_foldPCA = zeros(1,5);
SL.RF_avg_noPCA = zeros(1,5);
SL.RF_avg_onePCA = zeros(1,5);
SL.RF_avg_foldPCA = zeros(1,5);


%% 

for i = 1:5

    [X_SL_500_shuf,Y_SL_500_shuf] = shuffleData(X_Sl_500, Y_Sl_500, 'rngType', i);
    [X_SL_100_shuf,Y_SL_100_shuf] = shuffleData(X_Sl_100, Y_Sl_100, 'rngType', i);

    LDA_noAvg_noPCA = classifyCrossValidateMulti(X_SL_100_shuf, Y_SL_100_shuf, ...
        'PCA', -1, 'classifier', 'LDA');
    LDA_noAvg_onePCA = classifyCrossValidateMulti(X_SL_100_shuf, Y_SL_100_shuf, ...
        'PCA', .99, 'PCAinFold', 0, 'classifier', 'LDA');
    LDA_noAvg_foldPCA = classifyCrossValidateMulti(X_SL_100_shuf, Y_SL_100_shuf, ...
        'PCA', .99, 'PCAinFold', 1, 'classifier', 'LDA');
    LDA_yesAvg_noPCA = classifyCrossValidateMulti(X_SL_500_shuf, Y_SL_500_shuf, ...
        'PCA', -1, 'classifier', 'LDA');
    LDA_yesAvg_onePCA = classifyCrossValidateMulti(X_SL_500_shuf, Y_SL_500_shuf, ...
        'PCA', .99, 'PCAinFold', 0, 'classifier', 'LDA');
    LDA_yesAvg_foldPCA = classifyCrossValidateMulti(X_SL_500_shuf, Y_SL_500_shuf, ...
        'PCA', .99, 'PCAinFold', 1, 'classifier', 'LDA');
    
    SL.LDA_noAvg_noPCA(i) = LDA_noAvg_noPCA.accuracy;
    SL.LDA_noAvg_onePCA(i) =  LDA_noAvg_onePCA.accuracy;
    SL.LDA_noAvg_foldPCA(i) = LDA_noAvg_foldPCA.accuracy;
    SL.LDA_yesAvg_noPCA(i) = LDA_yesAvg_noPCA.accuracy;
    SL.LDA_yesAvg_onePCA(i) = LDA_yesAvg_onePCA.accuracy;
    SL.LDA_yesAvg_foldPCA(i) = LDA_yesAvg_foldPCA.accuracy;
    
end
