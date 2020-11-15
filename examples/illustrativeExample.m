%% 1. Define colors and category labels

% a) create cell array to store colors for visualization
rgb6 = {'blue', 'cyan', 'green', 'red', 'magenta', 'black'};

% b) create category label names
catLabels = {'HB', 'HF', 'AB', 'AF', 'FV', 'IO'};


%% 2. load input data

% a) X contains the EEG data in 3D, space-by-time-by-trial format 
%   labels6 and labels72 contain the trial categories
%   t contains the timepoints of the input data in ms
%   fs contains the sampling frequency
%   subID contains the subject ID of the experiment
%   
load '../UnitTests/S06.mat'
Y = labels6;

% b) plot histrogram to show that each category is evenly distributed
histogram(labels6)
title('Distribution of class labels')
xticklabels(catLabels);
xlabel('category name');
ylabel('number of trials');

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
    plot(t, mean(temp,2), 'w',...
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

% a) we want to shuffle the data so that when our data is used for
% classification, each class is represented in every cross validation fold.
% b) Also, we set the random seed so the result is replicable across disparate 
% calls to the function
[X_shuf, Y_shuf] = RSA.Preprocessing.shuffleData(X, Y, NaN, 0);

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
[X_avg, Y_avg] = RSA.Preprocessing.averageTrials(X_shuf, Y_shuf, 5);

% c) show number of trials before and after averaging
length(labels6)
length(Y_avg)

% d) visualization of single trial before and after averaging.  Trials
% should be less noisy after averaging
figure
plot(t, X(1, :, 1))
hold on
plot(t, X_avg(1, :, 1))
legend({'before averaging', 'after averaging'});
xlabel('time');
ylabel('amplitude');


%% 8. Multiclass classification (all electrodes, all time points)

%% a, c)  LDA classification/visualization

C_LDA = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, 'classifier', 'LDA');

figure
RSA.Visualization.plotMatrix(C_LDA.CM, 'colorbar', 1, 'matrixLabels', 1);
RDM_LDA = RSA.RDM_Computation.CM2RDM(C_LDA.CM);

figure
RSA.Visualization.plotMatrix(RDM_LDA, 'colorbar', 1, 'matrixLabels', 1);

figure
RSA.Visualization.plotDendrogram(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);

figure
RSA.Visualization.plotMDS(RDM_LDA, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);

%% b, c) SVM classification/visualization

C_SVM = RSA.Classification.crossValidateMulti_opt(X_avg, Y_avg, 'PCA', .99, 'classifier', 'SVM');

% gamma_opt = .0032;
% C_opt = 100000;
% C_SVM = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
%    'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt);

figure
RSA.Visualization.plotMatrix(C_SVM.CM, 'colorbar', 1, 'matrixLabels', 1);
RDM_SVM = RSA.RDM_Computation.CM2RDM(C_SVM.CM);

figure
RSA.Visualization.plotMatrix(RDM_SVM, 'colorbar', 1, 'matrixLabels', 1);

figure
RSA.Visualization.plotDendrogram(RDM_SVM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);

figure
RSA.Visualization.plotMDS(RDM_SVM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);



%% 9. Multiclass classification: Spatially resolved
% 96 is the good electrode, 122 is the bad one

% a), b) LDA classification on electrode 96
C_96 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 96);

% a), c) LDA classification on electrode 122
C_122 = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 122);

% d) LDA classification on electrode 122
figure
RSA.Visualization.plotMatrix(C_96.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Electrode 96 Confusion Matrix (Good)')
colormap('cool');
figure
RSA.Visualization.plotMatrix(C_122.CM, 'colorbar', 1, 'matrixLabels', 1);
title('Electrode 122 Confusion Matrix (Bad)')
colormap('cool');

% e) If we repeat this process for every electrode on the brain, 
%    per-electrode accuracies can be visualized on a head map 

%% 10. Multiclass classification: temporally resolved 
% 48-128 msec should separate HF/AF from other categories
% 144-224 msec should separate HF from other categories

% a), b) LDA classification on electrode 96
C_HFAF = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'timeUse', 11:16);

% a), c) LDA classification on electrode 122
C_HF = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'spaceUse', 17:23);

% d) LDA classification on electrode 122
figure
RSA.Visualization.plotMatrix(C_HFAF.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels);
title('48-128 msec Confusion Matrix (HF/AF should separate)')
colormap('cool');
figure
RSA.Visualization.plotDendrogram(C_HFAF.CM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('48-128 msec Dendrogram Matrix (HF/AF should separate)')

figure
RSA.Visualization.plotMatrix(C_HF.CM, 'colorbar', 1, 'matrixLabels', 1, ...
    'axisLabels', catLabels);
title('144-224 msec Confusion Matrix (HF should separate)')
colormap('cool');
figure
RSA.Visualization.plotDendrogram(C_HF.CM, 'nodeLabels', catLabels, ...
    'nodeColors', rgb6);
title('144-224 msec Dendrogram Matrix (HF should separate)')

