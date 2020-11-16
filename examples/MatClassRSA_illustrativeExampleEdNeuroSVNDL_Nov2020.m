% MatClassRSA_illustrativeExampleEdNeuroSVNDL_Nov2020.m
% ------------------------------------------------------
% November 17, 2020
% Author: Bernard Wang
%
% This script covers basic functionalities of the MatClassRSA toolbox: 
% - Instantiating the MatClassRSA class;
% - Data preparation: Call shuffleData()
% - Data prepraation: Call averageTrials()
% - 
%
% This script is intended to be run cell by cell as a tutorial.
%
% The demo uses a set of time-domain visual evoked potentials from this
% 	paper: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0135697
% There are 72 visual stimuli, 12 in each of 6 object categories. Each
%   participant viewed each stimulus 72 times. We will look at responses on
%   the category level, meaning there are 
%       12 stimuli x 72 viewings per stimulus = 864 trials per category.
%
% Requirements to run the tutorial: 
% - The MatClassRSA toolbox, dev2 branch, is in your path: 
%   https://github.com/berneezy3/MatClassRSA
% - The S06.mat data file is in your path.


%% 1. Define colors and category labels

% a) create cell array to store colors for visualization
rgb6 = {[0.1216    0.4667    0.7059],  ... % Blue
    [1.0000    0.4980    0.0549] ,     ...   % Orange
    [0.1725    0.6275    0.1725] ,   ...     % Green
    [0.8392    0.1529    0.1569]  ,    ...   % Red
    [0.5804    0.4039    0.7412]  ,   ...    % Purple
    [0.7373    0.7412    0.1333]}   ,  ...   % Chartreuse

% b) create category label names
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};


%% 2. load input data

% a) X contains the EEG data in 3D, space-by-time-by-trial format 
%   labels6 and labels72 contain the trial categories
%   t contains the timepoints of the input data in ms
%   fs contains the sampling frequency
%   subID contains the subject ID of the experiment
%   
load 'S06.mat'
Y = labels6;

% b) plot histrogram to show that each category is evenly distributed
h = histogram(labels6) ;
% Plot the number of observations for each category
x = h.BinEdges + h.BinWidth/2;
y = h.Values ;
text(x(1:end-1),y,num2str(y'),'vert','top','horiz','center',...
    'fontsize', 12); 

title('Distribution of stimulus category labels')
xticklabels(catLabels);
xlabel('Category name');
ylabel('Number of trials');
set(gca, 'fontsize', 16)

%% 3. visualize input data

% Channel 96 is known to be a good channel. So let's plot the mean of each
% category at that electrode

%%% Here we plot all 6 mean ERPs in a single figure %%%
close all
figure(); hold on

% 'X' is the data frame (electrodes x time x trial)


% Here we iterate through the 6 categories and plot the mean of that
% category, all in a dingle plot.
for i = 1:6
    
    % This is the data for the current category i
    % time x trials
    temp = squeeze(X(96, :, Y==i));
    
    % Plot current mean and color by category
    % X-values are our pre-loaded time vector in msec
    % Y-values are the mean data across the 2nd (trial) dimension
    plot(t, mean(temp,2), 'color', rgb6{i},...
        'linewidth', 2);
    
end

% Aesthetics

%%% Add grid, legend, axis labels, title; set font size %%%
grid on
% Add the legend with our cell array of category labels
legend(catLabels)

% Label your axes!
xlabel('Time (msec)'); ylabel('Voltage (\muV)')

% Add title
title('6-class ERP, channel 96')

% Make font size a bit larger
set(gca, 'fontsize', 16)

%% 4. visualize input data pt 2

close all
%%% Here we extend previous 'for' loop to do one category per figure %%%
%%% (Plot aesthetics will go inside the loop now) %%%
% 'X' is the data frame (electrodes x time x trial)

% Now we're going to make a separate figure for each category. In each
% figure we'll plot the first 50 single trials, colored by category, as
% well as the mean across all trials in black.
figure()
for i = 1:6
    
    % Initiate the current subplot
    subplot(2, 3, i)
    
    % Subset out the data for the current stim category
    % time x trials
    temp = squeeze(X(96, :, Y==i));
    
    % Plot 50 single trials from each category
    % X-values are our pre-loaded time vector in msec
    % Y-values are the single trials (matlab will automatically plot all
    %       columns if given a matrix to plot)
    % Color by category
    % Thinner linewidth here since we have a lot of single trials
    plot(t, temp(:, 1:50), 'color', rgb6{i},...
        'linewidth', 1);
    hold on;
    
    % Plot current mean and color by category
    % We take the mean across the 2nd (trial) dimension
    % Color the mean white and use a larger linewidth
    plot(t, mean(temp,2), 'k',...
        'linewidth', 2);
    
    % Our aesthetics from before
    grid on
    xlabel('Time (msec)'); ylabel('Voltage (\muV)')
    ylim([-40 40])
    
    % We can programmatically include the category number in the title!
    title([catLabels{i} ' 6-class ERP, channel 96'])
    
    set(gca, 'fontsize', 16)
    
end

%% 5. instantiating the an instance of the MatClassRSA class

% a) The object RSA will be the gateway to our EEG classification functions
RSA = MatClassRSA;

%% 6. call shuffleData()

% a) we want to shuffle the data so that whsen our data is used for
% classification, each class is represented in every cross validation fold.
% b) Also, we set the random seed so the result is replicable across disparate 
% calls to the function
[X_shuf, Y_shuf] = RSA.Preprocessing.shuffleData(X, Y, 'randomSeed', 0);

%% 7. call averageTrials()

% a) Averaging trials of the same label may help our analyses in a couple 
% ways: the resultant trials become less noisy than the original trials,
% which may improve the model performance.  Also doing so decreases the
% runtime, since averaging trials decreases the total number of trials we
% analyze.
%
% If number of trials are not divisible by the averaging factor, then we
% discard the extra trials
% b)
[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(X_shuf, Y_shuf, 5, 'randomSeed', 0);

% c) show number of trials before and after averaging
length(labels6)
length(Y_avg)

% d) visualization of 10 single trial before and after averaging. 
% We can see that pseudotrials are less noisy than unaveraged single trials
figure

stIndx = find(Y==1);
stIndx = stIndx(1:10);
ptIndx = find(Y_avg==1);
ptIndx = ptIndx(1:10);

subplot(2,1,1)
plot(t, squeeze(X(96, :, stIndx)), 'color', rgb6{1},...
    'linewidth', 1);
ylabel('amplitude');
title('10 Single Trials, electrode 96');
legend({'before averaging'});
set(gca, 'fontsize', 16)


subplot(2,1,2)
plot(t, squeeze(X_avg(96, :, ptIndx)), 'color', rgb6{1},...
    'linewidth', 1);
title('10 Pseudo Trials (5 single-trials averaged), electrode 96')
legend({'after averaging'});
xlabel('time');
ylabel('amplitude');
set(gca, 'fontsize', 16)


%% 8. Multiclass classification (all electrodes, all time points)

%% a, c)  LDA classification/visualization

% We perform cross validation using the LDA classififier on X_avg and Y_avg.
% PCA is specified to choose principal components that explain 99% of the 
% variance of the data.
C_LDA = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, 'classifier', 'LDA');

% Plot the confusion matrix computed by the cross validation using the
% visualization function, RSA.Visualization.plotMatrix()
figure
RSA.Visualization.plotMatrix(C_LDA.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Multiclass LDA Confusion Matrix');
set(gca, 'fontsize', 16)

% Next, we call the RSA.RSA.RDM_Computation.computeCMRDM() function to
% convert the confusion matrix into a Representational Dissimilarity
% Matrix(RDM).   
RDM_LDA = RSA.RDM_Computation.computeCMRDM(C_LDA.CM);

% We use plotMatrix() again to visualize the RDM. 
figure
RSA.Visualization.plotMatrix(RDM_LDA, 'colorbar', 1, 'matrixLabels', 1);
title('Multiclass LDA RDM');
set(gca, 'fontsize', 16)

% We pass the previously computed RDM into the 
% RSA.Visualization.plotDendrogram() function to create a dendrogram
% visualiation.  The 'nodeLabels' and 'nodeColors' arguments set the
% dendrogram leaf labels and colors, respectively.  
figure
RSA.Visualization.plotDendrogram(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('Multiclass LDA Dendrogram Dendrogram');
set(gca, 'fontsize', 16)

% We pass the previously computed RDM into the 
% RSA.Visualization.plotMDS() function to create a multidimentional scaling
% visualiation.  The 'nodeLabels' and 'nodeColors' arguments set the
% category coordinate labels and colors, respectively.  
figure
RSA.Visualization.plotMDS(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('Multiclass LDA MDS Plot');
set(gca, 'fontsize', 16)

%% b, c) SVM classification/visualization

% C_SVM = RSA.Classification.crossValidateMulti_opt(X_avg, Y_avg, 'PCA', .99, 'classifier', 'SVM');

% We perform cross validation using the SVM classififier on X_avg and Y_avg.
% PCA is specified to choose principal components that explain 99% of the 
% variance of the data.
% 'gamma' and 'C' are hyperparameters of SVM's rbf kernel.  gamma_opt and 
% C_opt were computed using the RSA.ClassificationcrossValidateMulti_opt() 
% function.   
gamma_opt = .0032;
C_opt = 100000;
C_SVM = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt);

% Plot the confusion matrix computed by the cross validation using the
% visualization function, RSA.Visualization.plotMatrix()
figure
RSA.Visualization.plotMatrix(C_SVM.CM, 'colorbar', 1, 'matrixLabels', 1);
set(gca, 'fontsize', 16)
title('Multiclass SVM Confusion Matrix');

% Next, we call the RSA.RDM_Computation.computeCMRDM() function to convert
% the confusion matrix into a Representational DissimilarityMatrix(RDM).
RDM_SVM = RSA.RDM_Computation.computeCMRDM(C_SVM.CM);

% We use plotMatrix() again to visualize the RDM. 
figure
RSA.Visualization.plotMatrix(RDM_SVM, 'colorbar', 1, 'matrixLabels', 1);
set(gca, 'fontsize', 16)
title('Multiclass SVM RDM');

% We pass the previously computed RDM into the 
% RSA.Visualization.plotDendrogram() function to create a dendrogram
% visualiation.  The 'nodeLabels' and 'nodeColors' arguments set the
% dendrogram leaf labels and colors, respectively.  
figure
RSA.Visualization.plotDendrogram(RDM_SVM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
set(gca, 'fontsize', 16)
title('Multiclass SVM Dendrogram');
ylabel('Similarity')

% We pass the previously computed RDM into the 
% RSA.Visualization.plotMDS() function to create a multidimentional scaling
% visualiation.  The 'nodeLabels' and 'nodeColors' arguments set the
% category coordinate labels and colors, respectively.  
figure
RSA.Visualization.plotMDS(RDM_SVM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
set(gca, 'fontsize', 16)
title('Multiclass SVM MDS');


%% 9. Multiclass classification: Spatially resolved
% Setting the 'spaceUse' input argument on 3D, space-by-time-by-trial data 
% selects the electrode of interest, then uses data from that electrode exclusively 
% to perform classification.
% In this example, electrode #96 is the one which performs well, while #122
% should not perform well.
% In addition, we set the 'PCA' argument to .99 to conduct principal
% component analysis, such that the components selected explain 99% of the
% variance in the data

% a), b) LDA classification on electrode 96
C_96 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 96);

% a), c) LDA classification on electrode 122
C_122 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 122);

% d) Compare the confusion matrices of electrode 122 and 96.  
figure
RSA.Visualization.plotMatrix(C_96.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Electrode 96 Confusion Matrix (good electrode)')
set(gca, 'fontsize', 16)

figure
RSA.Visualization.plotMatrix(C_122.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Electrode 122 Confusion Matrix (bad electrode)')
set(gca, 'fontsize', 16)


% e) If we repeat this process for every electrode on the brain, 
%    per-electrode accuracies can be visualized on a head map 

%% 10. Multiclass classification: temporally resolved 
% Setting the 'timeUse' input argument on 3D, space-by-time-by-trial 
% data from the specified time samples to perform classification.
% 48-128 msec should separate HF/AF from other categories.
% 144-224 msec should separate HF from other categories.
% Again, PCA is specified to choose principal components that explain 99%
% of the variance of the data.

% a), b) LDA cross validation on 48-128 msec
C_HFAF = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 11:16);

% a), c) LDA cross validation on 144-224 msec
C_HF = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 17:23);

% d) Compare the confusion matrices of from 48-128 msec to 144-224 msec
figure
RSA.Visualization.plotMatrix(C_HFAF.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels);
RDM_HFAF = RSA.RDM_Computation.computeCMRDM(C_HFAF.CM);
title('48-128 msec Confusion Matrix (HF,AF should separate)')
figure
RSA.Visualization.plotDendrogram(RDM_HFAF, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('48-128 msec Dendrogram Matrix (HF,AF should separate)')
ylabel('Similarity')


figure
RSA.Visualization.plotMatrix(C_HF.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels);
RDM_HF = RSA.RDM_Computation.computeCMRDM(C_HF.CM);
title('144-224 msec Confusion Matrix (HF should separate)')
figure
RSA.Visualization.plotDendrogram(RDM_HF, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('144-224 msec Dendrogram Matrix (HF should separate)')
ylabel('Similarity')
