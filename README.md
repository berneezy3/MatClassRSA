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

The external dependency, LIBSVM, must be set up before any SVM classifications 
can be performed. Once inside the MatClassRSA main directory, navigate to
src/libsvm-3.21/matlab and refer to the README file there for LIBSVM 
installation instructions.

Upon startup of Matlab, run the following in the Matlab IDE to add the 
MatClassRSA functions into your search path:

> MatClassRSAPath = ‘path/to/your/directory/in/char/format’;
> addpath(genpath(MatClassRSAPath));

MatClassRSA functions will be runnable from this point.  To automatically 
import MatClassRSA upon Matlab startup, please create a ‘startup.m’ 
somewhere in your Matlab search path (this can be found using the command “path”), 
and add the above lines into it.  

Conditions of Use:

MatClassRSA is a free MATLAB software; users are free to redistribute and/or modify it under the terms of 
The 3-Clause BSD License (New BSD License) published in the public domain.  The terms of the license are as follows:

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

Support:
For questions, comments, suggestions, feature requests, and bug reports, please contact bernardcwang@gmail.com
