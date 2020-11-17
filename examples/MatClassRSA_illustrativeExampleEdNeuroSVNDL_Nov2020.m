% MatClassRSA_illustrativeExampleEdNeuroSVNDL_Nov2020.m
% ------------------------------------------------------
% November 17, 2020
% Author: Bernard Wang
%
% This script covers basic functionalities of the MatClassRSA toolbox: 
% - Instantiating the MatClassRSA class
% - Data preparation: Call shuffleData(), averageTrials()
% - Classification: Call crossValidateMulti(), crossValidateMulti_opt()
% - RDM computation: computeCMRDM()
% - Visualization: Call plotMatrix(), plotMDS() and plotDendrogram()
%
% This script is intended to be run cell by cell as a tutorial.
%
% Requirements to run the tutorial: 
% - The MatClassRSA toolbox, dev2 branch, is in your path: 
%   https://github.com/berneezy3/MatClassRSA
% - The S06.mat data file is in your path
% * the matlab addpath() function can be used to add directories to your
%   Matlab path
%
% Information about the data:
% - The demo uses a set of time-domain visual evoked potentials from this
% 	paper: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0135697
% - There are 72 visual stimuli, 12 in each of 6 object categories (Human 
%   body, human face, animal body, animal face, fruits/vegetables and 
%   inanimate objects). The participant viewed each stimulus 72 times. We 
%   will look at responses on the category level, meaning there are: 
%       12 stimuli x 72 viewings per stimulus = 864 trials per category.
%



%% 1. Define colors and category labels

clear all; close all; clc

% a) create cell array to store colors for visualization
rgb6 = {[0.1216    0.4667    0.7059],  ...  % Blue
    [1.0000    0.4980    0.0549] ,     ...  % Orange
    [0.1725    0.6275    0.1725] ,     ...  % Green
    [0.8392    0.1529    0.1569]  ,    ...  % Red
    [0.5804    0.4039    0.7412]  ,    ...  % Purple
    [0.7373    0.7412    0.1333]};          % Chartreuse

% b) create category label names
%   HB = Human Body
%   HF = Human Face
%   AB = Animal Body
%   AF = Animal Face
%   FV = Fruit / Vegetable
%   IO = Inanimate Object
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};


%% 2. load input data

load 'S06.mat'

%%% a) Variables from input .mat file: 
%   - X: 3D EEG electrode-by-time-by-trial data matrix (124 x 40 x 5184)
%   - labels6: Category-level labels of trials (5184 x 1)
%   - labels72: Exemplar-level labels of trials (5184 x 1)
%   - t: Time axis for EEG data, in msec (1 x 40)
%   - fs: Sampling rate (62.5 Hz)
%   - subID: Subject identifier ('06')
%   - blCorrectIdx: Time sample numbers used for baseline correction

% We'll work with category labels for the following examples --> Y.
Y = labels6;

%%% b) plot histrogram to show that the trials are evenly distributed
%%% amongst the different categories
close all; 
h = histogram(labels6);
% Plot the number of observations for each category
x = h.BinEdges + h.BinWidth/2;
y = h.Values;
text(x(1:end-1),y,num2str(y'),'vert','top','horiz','center',...
    'fontsize', 16); 

title('Distribution of stimulus category labels')
xticklabels(catLabels);
xlabel('Category name');
ylabel('Number of trials');
set(gca, 'fontsize', 16)

%% 3. visualize input data

% Channel 96 is known to be a good channel, in that its data produces a 
%   high classification accuracy. So let's plot the mean category-level ERP
%   at that electrode.

%%% Here we plot all 6 mean ERPs in a single figure %%%
close all
figure(); hold on

% 'X' is the data frame (electrodes x time x trial)


% Here we iterate through the 6 categories and plot the mean of that
% category, all in a single plot.
for i = 1:6
    
    % This is the data for the current category i, electrode 96
    % time x trials
    temp = squeeze(X(96, :, Y==i));
    
    % Plot current mean and color by category
    % X-values are our pre-loaded time vector in msec
    % Y-values are the mean data across the 2nd (trial) dimension
    plot(t, mean(temp,2), 'color', rgb6{i},...
        'linewidth', 2);
    
end

% Plot Aesthetics and Labels

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

% We see characteristic P1-N170 peaks of a visual evoked response. In
%   addition, we see that the Human Face N170 is earlier and larger 
%   compared to the other categories. 

%% 4. visualize input data pt 2

% close existing figures
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
    % Color the mean black and use a larger linewidth
    plot(t, mean(temp,2), 'k',...
        'linewidth', 2);
    
    % Our aesthetics from before
    grid on
    xlabel('Time (msec)'); ylabel('Voltage (\muV)')
    ylim([-40 40])
    xlim([-112 512])
    set(gca, 'fontsize', 16)
    
    % We can programmatically include the category number in the title!
    title([catLabels{i} ' 6-class ERP, channel 96'])
    
end

% Category means are visible to some extent in the single trials.

%% 5. instantiating the an instance of the MatClassRSA class

% a) MatClassRSA functions are called via an instance of the MatClassRSA 
%   class. Therefore, we first need to instantiate the class and assign it 
%   to a variable (in this case, the variable 'RSA'). This class instance 
%   'RSA' will be the gateway to our EEG classification functions.
RSA = MatClassRSA;

% Note that while other variables in our workspace are of class 'double',
%   'cell', etc., RSA is of class MatClassRSA: 
whos RSA
%   Name      Size            Bytes  Class          Attributes
%   RSA       1x1                 0  MatClassRSA   

%% 6. call shuffleData()

% a) In many cases it's good to shuffle the data prior to analysis -- e.g., 
%   if there are ordering effects or if the data matrix has data from 
%   participants concatenated one after the other, shuffling will ensure 
%   that data are distributed among all of the training and test 
%   partitions. The MatClassRSA shuffleData() function (inside the 
%   Preprocessing module) shuffles the EEG data matrix along the trial 
%   dimension, and also shuffles the labels vector accordingly so that EEG
%   trials remain mapped to the correct stimulus label.

% Functions are called via the instance of MatClassRSA. Preprocessing
% functions (like shuffleData()) are in the Preprocessing module and are
% called via the following dot syntax: 
[X_shuf, Y_shuf] = RSA.Preprocessing.shuffleData(X, Y, 'randomSeed', 0);

% Note that in the above function call we are including an optional
%   name-value pair to set the random seed. This is done so that the
%   outputs of this tutorial will replicate exactly over multiple
%   executions of the data.

%% 7. call averageTrials()

% a) Averaging trials within-category -- into what Guggenmos et al. refer 
%   to as 'pseudotrials' -- may help our analyses in two ways:
%   - Averaging improves SNR, which may improve classifier performance.  
%   - Averaging trials into 'pseutrials' also reduces the number of
%     observations being input to the classifier, which reduces runtime.
% There may be a trade-off between number of observations (higher when
%   working with single trials) and 'quality' (SNR) of observations
%   (higher when working with pseudotrials). That is, at some point, the
%   reduction in number of observations from trial averaging may outweigh
%   the benefits of improved SNR. This is a topic of planned future
%   analysis.

% b) We call the averageTrials() function, which is also in the
%   Preprocessing module. We input the EEG data, labels vector, as well as
%   the number of single trials we wish to average in each pseudotrial
%   output. The function will split the available trials for each stimulus
%   label and average accordingly.
[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(X_shuf, Y_shuf, 5, ... 
    'randomSeed', 0);
% Note that we again set the random seed for reproducibility.

% Whereas we had 5184 trials to begin with, we now have 1032 trials.
% - Size of X_avg: 124 x 40 x 1032
% - Size of Y_avg: 1032 x 1

%% 8. Visualize observations before and after trial averaging

% d) We can visualize 10 single trials (before trial averaging) and 10
%   pseudotrials (after trial averaging) to make a visual comparison.

close all
figure

% Get indices of trials and pseudotrials from category 1
stIndx = find(Y==1);
stIndx = stIndx(1:10);
ptIndx = find(Y_avg==1);
ptIndx = ptIndx(1:10);

% Plot single trials
subplot(2,1,1)
plot(t, squeeze(X(96, :, stIndx)), 'color', rgb6{1},...
    'linewidth', 1);
ylabel('amplitude'); grid on
title('10 Single Trials, electrode 96, HB category');
legend({'before averaging'});
set(gca, 'fontsize', 16)


subplot(2,1,2)
plot(t, squeeze(X_avg(96, :, ptIndx)), 'color', rgb6{1},...
    'linewidth', 1);
title('10 Pseudo Trials, electrode 96, HB category')
legend({'after averaging'});
xlabel('Time (msec)');
ylabel('amplitude'); grid on
set(gca, 'fontsize', 16)

% By inspection of the plots, we can see that there is less variance among
%   the pseudotrials compared to the single trials.

%% 9. Multiclass classification (all electrodes, all time points)

% We will now perform some multi-category classifications on the
% trial-averaged data. In this example, we will compare results using 2
% different classifiers, support vector machine (SVM) and linear 
% discriminant analysis.   

%% 9a_i) Perform LDA classification

% We perform cross validation using the LDA (linear discriminant analysis) 
%   classififier on X_avg and Y_avg. LDA is a fairly simple linear
%   classifier: It computes linear boundaries between classes, and does not
%   have any hyperparameters that need to be optimized. 

% We call the crossValidateMulti() function from the Classification module.
%   This function does multicategory (vs pairwise) classification, and
%   iteratively trains and tests the data using cross validation. 
C_LDA = RSA.Classification.crossValidateMulti(X_avg, Y_avg,... 
    'PCA', .99, 'classifier', 'LDA');

% Note that we input the following variables and specifications: 
%   - X_avg: Trial-averaged data
%   - Y_avg: Corresponding labels vector
%   - 'PCA', .99: This is an optional name-value pair for reducing the data 
%     dimensionality using PCA. In this case we are asking the function to 
%     retain as many principal components as are needed to explain 99% of 
%     the variance of the data when it's in trial-by-feature form.
%   - 'classifier', 'LDA': This name-value pair specifies that we want to
%     use the LDA classifier (which is also the default classifier). We'll
%     use a different classifier shortly.

% The classification function outputs a struct with fields for the
%   confusion matrix (C_LDA.CM), overall accuracy (C_LDA.accuracy), etc.
C_LDA
% C_LDA = 
% 
%   struct with fields:
% 
%                     CM: [6×6 double]
%               accuracy: 0.7447
%     classificationInfo: [1×1 struct]
%           modelsConcat: {1×10 cell}
%                  predY: [1×1030 double]
%       dataPartitionObj: [1×1 struct]
%            elapsedTime: 2.3489
%                   pVal: NaN

%% 9a_ii) Convert LDA confusion matrix to a distance matrix

% We can now visualize the outputs of the classifier using functions in the
%   Visualization module. 

% First, we call plotMatrix() to display the confusion matrix in a figure.
%   This function takes in a square matrix, and has a number of optional 
%   name-value pairs for plotting specifications. 
close all
figure(1)
RSA.Visualization.plotMatrix(C_LDA.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Multiclass LDA Confusion Matrix');
set(gca, 'fontsize', 16)

% You may recall that classifier confusions (as stored in the confusion 
%   matrix) can be treated as measures of similarity. However, in order to 
%   create the other plots, we need a distance matrix instead. Thus, we 
%   call the computeCMRDM() function to convert the confusion matrix into 
%   a Representational Dissimilarity Matrix(RDM).   
RDM_LDA = RSA.RDM_Computation.computeCMRDM(C_LDA.CM, ...
    'normalize', 'diagonal');
% This function performs a few steps: It normalizes the data, makes sure
%   the matrix is symmetric, and then converts similarities to distances.
%   We are including one optional name-value pair in order to normalize
%   the matrix with a non-default configuration. We will cover the steps
%   of the RDM computation in a future tutorial. 

RDM_LDA
% RDM_LDA =
% 
%          0    0.9930    0.9428    0.9225    0.9014    0.8589
%     0.9930         0    0.9963    0.9923    0.9856    0.9456
%     0.9428    0.9963         0    0.9093    0.9378    0.9374
%     0.9225    0.9923    0.9093         0    0.9221    0.9542
%     0.9014    0.9856    0.9378    0.9221         0    0.6761
%     0.8589    0.9456    0.9374    0.9542    0.6761         0


% We use plotMatrix() again to visualize the RDM. 
figure(2)
RSA.Visualization.plotMatrix(RDM_LDA, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
title('Multiclass LDA RDM');
set(gca, 'fontsize', 16)

% Comparing the two figures:
%   - Element i, j of matrix: In Figure 1 these are the number of
%     observations from category i that the classifier labeled as being
%     from category j. In Figure 2 these are the distances between classes
%     i and j. 
%   - Diagonal entries: In Figure 1 these are the number of correct
%     classifications for each category. In Figure 2 the diagonal is zero
%     (distance between a class and itself is zero).
%   - Off-diagonal entries: In Figure 1 larger values meant greater
%     similarity. In Figure 2, larger values mean greater distance. Hence,
%     in Figure 1, classes 5 and 6 has large off-diagonal values (high
%     similarity) while in Figure two they have small off-diagonal values
%     (low distance). 
%   - The form of the data in Figure 2 is commonly reported in studies
%     using EEG classification to study neural proximity/distance spaces.

%% 9a_iii) Visualize hierarchical structure of the RDM using a dendrogram

% Now that we have computed the RDM, we can pass it into other functions 
%   in the Visualization module. For instance, we can call the 
%   plotDendrogram() function to create a tree visualiation.  
figure(3)
RSA.Visualization.plotDendrogram(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('Multiclass LDA Dendrogram Dendrogram');
set(gca, 'fontsize', 16); ylabel('Distance')
% The optional name-value 'nodeLabels' and 'nodeColors' arguments set the 
%   dendrogram leaf labels and colors, respectively.  

% How to interpret the dentrogram: Each node at the bottom of the plot is a
%   stimulus category. The y-axis denotes distance. The distance between
%   any two categories is how far up the tree you have to go to get from
%   one category to another. Therefore, FV and IO are very close, while the
%   HF category is the most distant from the other categories. We can also
%   say that the top 'split' of the dendrogram separates HF from the other
%   categories, followed by a split separating out the animal (AB/AF)
%   categories, and then the remaining three categories.

%% 9a_iv) Visualize non-hierarchical structure of the RDM using MDS

% We can also visualize the RDM using multidimensional scaling (MDS). This 
%   approach enables us to visualize the distances among categories in 
%   low-dimensional spaces. To do this, we pass the RDM into the plotMDS() 
%   function. 
figure(4)
RSA.Visualization.plotMDS(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('Multiclass LDA MDS Plot');
set(gca, 'fontsize', 16)
% The 'nodeLabels' and 'nodeColors' arguments set the
% category coordinate labels and colors, respectively.  

% How to interpret the MDS plot: MDS dimensions are returned in descending
%   order of variance, which means that the first dimension is the
%   principal dimension, followed by dimensions 2, 3, etc. Therefore we
%   would say that Dimension 1 is separating out the FV and IO classes
%   together and the HB class, while Dimension 2 appears to be separating
%   the HF category from all the others. AF and AB are not easily separated
%   from one another along either of the two principal dimensions.

%% 9b_i) Perform SVM classification and optimize hyperparameters

% Another classifier available in MatClassRSA is support vector machine
%   (SVM). This classifier has more parameters than LDA and can potentially
%   perform better. However, it also has hyperparameters that need to be
%   optimized. This is done in a nested train-test fashion using train /
%   test / validation partitions (we can cover this topic in greater detail
%   in a future tutorial). 

% We can call the SVM classifier with hyperparameter optimization using the
%   same crossValidateMulti() function in the Classification module. In
%   this case we'll specify the SVM classifier. 
C_SVM_0 = RSA.Classification.crossValidateMulti_opt(X_avg, Y_avg,...
    'PCA', .99, 'classifier', 'SVM', 'randomSeed', 0);

% C_SVM_0 = 
%   struct with fields:
% 
%                     CM: [6×6 double]
%              gamma_opt: 0.0032
%                  C_opt: 100000
%               accuracy: 0.7553
%           modelsConcat: {1×10 cell}
%                  predY: [1×1030 double]
%     classificationInfo: [1×1 struct]
%            elapsedTime: 229.7094

% The above function call will take longer to run than LDA because it first
% tests different hyperparameters to gauge which one produces the highest
% classification accuracy, then uses the optimal hyperparameter for our
% cross validation.  This accuracy is slightly better than what we obtained 
% with LDA (74.47%).

%% 9b_ii) Perform SVM classification with specified hyperparameters
% 'gamma' and 'C' are hyperparameters of SVM's rbf kernel. gamma_opt and 
%   C_opt were computed using the above function call.   
gamma_opt = .0032;
C_opt = 100000;
C_SVM = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'randomSeed', 0);

% C_SVM = 
% 
%   struct with fields:
% 
%                     CM: [6×6 double]
%               accuracy: 0.7767
%     classificationInfo: [1×1 struct]
%           modelsConcat: {1×10 cell}
%                  predY: [1×1030 double]
%       dataPartitionObj: [1×1 struct]
%            elapsedTime: 9.1256
%                   pVal: NaN

% We get comparable results (should be identical -- we are working out a
%   bug with the random seed).

%% 9b_iii) Plot the SVM confusion matrix 

% Plot the confusion matrix computed by the cross validation using the
% visualization function, RSA.Visualization.plotMatrix()
figure
RSA.Visualization.plotMatrix(C_SVM.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
set(gca, 'fontsize', 16)
title('Multiclass SVM Confusion Matrix');

% We can see that the human face category produces the largest number of
% correct classifications (158) of all the categories.

%% 9b_iv) Convert SVM confusion matrix to a distance matrix

% Next, we call the RSA.RDM_Computation.computeCMRDM() function to convert
% the confusion matrix into a Representational Dissimilarity Matrix(RDM).

RDM_SVM = RSA.RDM_Computation.computeCMRDM(C_SVM.CM, 'normalize', 'diagonal');

% RDM_SVM =
%        0    0.9937    0.9637    0.9213    0.9470    0.8860
%   0.9937         0    0.9873    0.9961    0.9785    0.9752
%   0.9637    0.9873         0    0.8835    0.9578    0.9376
%   0.9213    0.9961    0.8835         0    0.9414    0.9620
%   0.9470    0.9785    0.9578    0.9414         0    0.7609
%   0.8860    0.9752    0.9376    0.9620    0.7609         0

% We use plotMatrix() again to visualize the RDM. 
figure
RSA.Visualization.plotMatrix(RDM_SVM, 'colorbar', 1, 'matrixLabels', 1, ...
                            'axisLabels', catLabels, 'axisColors', rgb6);
set(gca, 'fontsize', 16)
title('Multiclass SVM RDM');

%% 9b_v) Visualize hierarchical structure of the RDM using a dendrogram

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

%% 9b_vi) Visualize non-hierarchical structure of the RDM using MDS

% We can also pass the RDM into the RSA.Visualization.plotMDS() function to 
% create a multidimentional scaling plot.
figure
RSA.Visualization.plotMDS(RDM_SVM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
set(gca, 'fontsize', 16)
title('Multiclass SVM MDS');

% See steps 9a_iii and 9a_iv on how to interpret the dendrogram and MDS
% plots.


%% 10. Multiclass classification: Spatially resolved

% In this step, we will perform classification using data from individual 
% electrodes of our 3D input data matrix.  This is achieved by setting
% the 'spaceUse' input argument, which subsets the data along the space
% dimension prior to classification.  In this example, we will compare the
% cross validation results from electrode #96, which produces a high 
% classification accuracy, and electrode #122, which produces a relatively 
% lower classification accuracy.  

% In addition, we set the 'PCA' argument to .99 to conduct principal
% component analysis, such that the components selected explain 99% of the
% variance in the data

%% 10a) Conduct cross validation using the LDA classifier on electrode 96
C_96 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 96);

% C_96.accuracy: .5680;

%% 10b) Conduct cross validation using the LDA classifier on electrode 122
C_122 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 122);

% C_122.accuracy: .3019;
% We can see that the classification accuracy from electrode #122 is
% considerably lower than that of electrode #96

%% 10c) Compare the confusion matrices of electrode 122 and 96.  

figure
RSA.Visualization.plotMatrix(C_96.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
title('Electrode 96 Confusion Matrix (good electrode)')
set(gca, 'fontsize', 16)

figure
RSA.Visualization.plotMatrix(C_122.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
title('Electrode 122 Confusion Matrix (bad electrode)')
set(gca, 'fontsize', 16)

% Except for the human body category, we can see that the number of correct 
% categorizations along the diagonal  are lower when using electrode #122 
% compared to #96.  This suggests that the brain region associated w/
% electrode #96 contains more information relevent to the processing of
% stimuli category than #122.  

% By repeating this process for every EEG electrode, per-electrode
% accuracies can be visualized on a head map.

%% 11. Multiclass classification: temporally resolved 
% In this step, we will perform classification using data from specified 
% time intervals.  This is achieved by setting the 'timeUse' input 
% argument, which subsets the data along the time dimension prior to 
% classification.  In this example, we will compare the
% cross validation results from 48-128 msec, which should separate HF/AF 
% from other categories, and electrode #122, which should separate HF from 
% other categories.

% Again, PCA is specified to choose principal components that explain 99%
% of the variance of the data.

%% 11a) LDA cross validation on 48-128 msec

% The variable t from S06.mat contains the timepoints represented by the 
% indices along the 2nd dimension (time dim.) of the input data matrix, X.

t
t(17:23)
t(30:35)
% We can see that indices 17-23 represent 144-224 milliseconds, while 30-35
% represent 352 to 432 milliseconds.


%% 11b) LDA with cross validation

% We pass in the array 17:23 into the 'timeUse' argument to 
% subset data representing 144-224 milliseconds.   
C_144to224 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 17:23);
% accuracy: 0.8204
% Classifies better than using all time samples!

% We pass in the array 30:35 into the 'timeUse' argument to 
% subset data representing 352-432 milliseconds.   
C_352to432 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 30:35);
% accuracy: 0.3369
% Lower classifier accuracy.

%% 11c) Compare the confusion matrices of 48-128 msec to 144-224 msec

figure
RSA.Visualization.plotMatrix(C_144to224.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
title('144-224 msec Confusion Matrix (N170 region)')
set(gca, 'fontsize', 16)

figure
RSA.Visualization.plotMatrix(C_352to432.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels, 'axisColors', rgb6);
title('352-432 msec Confusion Matrix (later response)')
set(gca, 'fontsize', 16)

% The confusion matrix for 144:224 msec is nearly completely diagonal. The
%   greatest confusions occur between the FV / IO categories.
% The confusion matrix for 352:432 msec shows greater confusion higher
%   counts off the diagonal. But the HF category still classifies best.

%% 11d) Convert the confusion matrices into RDMs
% We convert the CMs into RDMs to create dendrogram visualizations in the
% next step.

RDM_144to224 = RSA.RDM_Computation.computeCMRDM(C_144to224.CM, 'normalize', 'diagonal');
RDM_352to432 = RSA.RDM_Computation.computeCMRDM(C_352to432.CM, 'normalize', 'diagonal');

%% 11c) Compare the dendrograms of 48-128 msec to 144-224 msec

figure
RSA.Visualization.plotDendrogram(RDM_144to224, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6, 'yLim', [0 1.5]);
title('144-224 msec Dendrogram')
ylabel('Distance')
set(gca, 'fontsize', 16)

figure
RSA.Visualization.plotDendrogram(RDM_352to432, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6, 'yLim', [0 1.5]);
title('352-432 msec Dendrogram')
ylabel('Distance')
set(gca, 'fontsize', 16)

% In the 144:224 msec dendrogram, the main split in the dendrogram 
%   separates HF from the other categories. FV and IO have the lowest 
%   distance. 
% In the 352:432 msec dendrogram, the main split separates FV and IO from
%   the other categories. However, these two categories no longer have the
%   smallest distance (that is now HB / AB). Overall the distances are
%   lower, due to more classifier confusions among the stimuli.
