# MatClassRSA
A MATLAB toolbox for M/EEG classification, proximity matrix construction, and visualization.

M/EEG classification involves constructing a statistical model from categorically labeled data observations. Such a model can then be used to predict labels of new observations. 
Representational Similarity Analysis (RSA) is a paradigm that allows quantitative comparison between stimulus responses across different data modalities (e.g., EEG, behavioral data) by abstracting data from each modality into Representational Dissimilarity Matrices (RDMs) that can be directly compared in a common unit space. Classification is useful for RSA, as pairwise classifier accuracies or multiclass classifier confusions can serve as measures of distance or similarity, respectively, across a stimulus set and can thus be used to construct the RDMs used for RSA.

## Information about the toolbox

MatClassRSA was created by [Bernard C. Wang](https://github.com/berneezy3), [Raymond Gifford](https://raymondgifford.com/), [Nathan C. L. Kong](https://scholar.google.com/citations?user=Iz9qpyUAAAAJ&hl=en&oi=sra), [Feng Ruan](https://fengruan.github.io/), [Anthony M. Norcia](https://profiles.stanford.edu/anthony-norcia), and [Blair Kaneshiro](https://ccrma.stanford.edu/~blairbo/).

For more information regarding the toolbox, please refer to the User Manual in this repository.

### Modules

MatClassRSA is organized into modules of user-called functions. The modules are as follows:
1. **Preprocessing.** This module includes functions to shuffle data trials (while retaining correct mapping to stimulus labels and participant labels if specified), average single trials from a given category (and participant, if specified), and normalize data from each sensor on the basis of SNR.
2. **Reliability.** This module contains functions to estimate the reliability of the data. Reliability can be calculated across available sensors and time points, as well as across varying sample sizes.
3. **Classification.** This module contains the main classification functions. Currently LDA, SVM (including hyperparameter optimization), and Random Forest classifiers are supported. The module includes functions for cross validation and user-specified train-test partitioning for multiclass and pairwise classifications. Classification functions also include simple permutation testing.
4. **RDM Computation.** This module includes RDM construction from classifier confusion matrices and pairwise accuracy matrices, as well as directly from the original data (with cross validation) based on Euclidean distance or Pearson correlation.
5. **Visualization.** This module includes a function to directly visualize RDMs, as well as functions that display the proximity space of an RDM as a dendrogram, Multidimensional Scaling plot, or Minimum Spanning Tree.

### Sub-directories

* **/ExampleData.** MatClassRSA includes illustrative analyses and example function calls that use example data. Due to their size, example data files are not provided in this repository, but can be automatically downloaded into this folder using the [illustrative_0_downloadExampleData.m](https://github.com/berneezy3/MatClassRSA/blob/master/IllustrativeAnalyses/illustrative_0_downloadExampleData.m) script in the IllustrativeAnalyses folder.

* **/ExampleFunctionCalls.** Contains specific example calls to the various MatClassRSA functions.

* **/src.** Location of all MatClassRSA functions and helper functions as well as the LIBSVM package. 

* **/IllustrativeAnalyses.** Location of illustrative analysis scripts.

### Dependencies

The software was tested on recent versions of MATLAB including R2021a
and R2024b.

The software requires two MATLAB toolboxes:  the Statistics and Machine 
Learning Toolbox and the Parallel Computing Toolbox.  Some of the 
illustrative analyses also require the Image Processing Toolbox.

The sole external dependency is LIBSVM, which is included in the src folder of this repository:

*Chang, Chih-Chung and Lin, Chih-Jen (2011). LIBSVM: A library for support vector machines.
ACM transactions on intelligent systems and technology (TIST), 2(3), 1-27. Software available
at http://www.csie.ntu.edu.tw/~cjlin/libsvm.*

LIBSVM must be set up before any SVM classifications 
can be performed. Once inside the MatClassRSA main directory, navigate to
src/libsvm-3.21/matlab and refer to the README file there for LIBSVM 
installation instructions.

## Getting started

To use MatClassRSA, download the latest version of this package at https://github.com/berneezy3/MatClassRSA/

Upon startup of Matlab, run the following in the Matlab IDE to add the 
MatClassRSA functions into your search path:

```
MatClassRSAPath = ‘path/to/your/directory/in/char/format’;
addpath(genpath(MatClassRSAPath));
```
MatClassRSA functions will be runnable from this point.  

## Citing the toolbox

If using MatClassRSA, please cite the following items:
* *Bernard C. Wang, Nathan C. L. Kong, Feng Ruan, Raymond Gifford, Anthony M. Norcia, and Blair Kaneshiro (2025). [MatClassRSA v2 Release: A MATLAB Toolbox for M/EEG Classification, Proximity Matrix Construction, and Visualization.](https://www.biorxiv.org/content/10.1101/2025.11.19.689115) bioRxiv 2025.11.19.689115. doi:10.1101/2025.11.19.689115*
* Please also cite the Zenodo record and DOI for the GitHub release, as referenced in the bibliography of the above preprint.

In addition, if using any of the toolbox's example data in outside projects, please cite the following dataset:
* *Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro (2025). Example Data for MatClassRSA v2 Release. Stanford Digital Repository. Available at https://purl.stanford.edu/kv831rr3606/. doi:10.25740/kv831rr3606.*

## Conditions of use

MatClassRSA is released under the MIT License 
(https://choosealicense.com/licenses/mit) as follows:

Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.

Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the 
"Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to 
the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Support
For questions, comments, suggestions, feature requests, and bug reports, 
please contact blairbo@ccrma.stanford.edu or bernardcwang@gmail.com.
