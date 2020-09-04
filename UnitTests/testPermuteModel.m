
%% test permute model for multiclass CV

permuteModel(C_multi.classifierInfo.dataPartitionObj, C_multi.classifierInfo.nFolds, 1000, C_multi.classifierInfo.nFolds, classifyOptions)

%% test permute model for pairwise CV

permuteModel(cvDataObj, nFolds, nPerms, classifier, classifyOptions)


%% test permute model for multiclass test/train

permuteModel(cvDataObj, nFolds, nPerms, classifier, classifyOptions)

%% test permute model for pairwise test/train

permuteModel(cvDataObj, nFolds, nPerms, classifier, classifyOptions)