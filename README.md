# MatClassRSA
Matlab toolbox for conducting classification and Representational 
Similarity Analyses (RSA) on M/EEG and other stimulus response data. 

RSA is a paradigm that allows quantitative comparison between stimulus 
responses between different modalities (e.g. EEG, behavioral data) by 
abstracting results into a dissimilartiy matrix.  More about RSA can be 
read here:

Nikolaus Kriegeskorte, Marieke Mur, and Peter A Bandettini. “Representational sim-
ilarity analysis - connecting the branches of systems neuroscience”. In: Frontiers in
Systems Neuroscience 2.4 (2008)

For more information regarding the toolbox, please refer to the user manual:

# INSERT LINK To Manual here #

Sub-directories:

/ExampleData - this directory will be created with the script:

    /IllustrativeAnalyses/illustrative_0_downloadExampleData.m

is run.  Data for the ilustrative analyses and example function calls will 
be stored here.

/ExampleFunctionCalls - Contains specific example calls to the various 
MatClassRSA functions.

/src - Location of all MatClassRSA functions and helper functions.

/IllustrativeAnalyses - Locations of examples and illustrative analyses.


Dependencies:

The software was tested on recent versions of MATLAB including R2021a
and R2024b.

The software requires two Matlab toolboxes:  the Statistics and Machine 
Learning Toolbox and the Parallel Computing Toolbox.  Some of the 
illustrative analyses also require the Image Processing Toolbox.

The sole external dependency is LIBSVM, which is included in the src folder of the Mat-
ClassRSA GitHub repository:

Chang, Chih-Chung and Lin, Chih-Jen (2011). LIBSVM: A library for support vector machines.
ACM transactions on intelligent systems and technology (TIST), 2(3), 1-27. Software available
at http://www.csie.ntu.edu.tw/~cjlin/libsvm.

To use MatClassRSA: 

Download the latest version of this package at https://github.com/berneezy3/MatClassRSA/

The external dependency, LIBSVM, must be set up before any SVM classifications can be
performed. Once inside the MatClassRSA main directory, navigate to
src/libsvm-3.21/matlab
and refer to the README file there for LIBSVM installation instructions.

Upon startup of Matlab, run the following in the Matlab IDE to add the MatClassRSA functions into your search path:

> MatClassRSAPath = ‘path/to/your/directory/in/char/format’;
> addpath(genpath(MatClassRSAPath));

MatClassRSA functions will be runnable from this point.  To automatically import MatClassRSA upon Matlab startup, 
please create a ‘startup.m’ somewhere in your Matlab search path (this can be found using the command “path”), 
and add the above lines into it.  

Conditions of Use:

MatClassRSA is a free MATLAB software; users are free to redistribute and/or modify it under the terms of 
The 3-Clause BSD License (New BSD License) published in the public domain.  The terms of the license are as follows:

Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
Redistribution and use in source and binary forms, with or without modification, are permitted provided that 
the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 
following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or 
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.


When MatClassRSA is used for research, please consider citing the publication describing the software package:
Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro (2017). MatClassRSA: A Matlab Toolbox for M/EEG Classification 
and Visualization of Proximity Matrices. bioRxiv preprint 194563; doi: https://doi.org/10.1101/194563.

For commercial use of MatClassRSA please contact Bernard Wang at: bernardcwang@gmail.com

Support:
For questions, comments, suggestions, feature requests, and bug reports, please contact bernardcwang@gmail.com

The EEG data for the example analyses presented here can be downloaded from the Stanford Digital Repository: 
https://purl.stanford.edu/bq914sc3730
