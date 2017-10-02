# MatClassRSA
Classification toolbox in Matlab for EEG data.  

This dir contains original Matlab functions from the EEGLAB (formerly ICA/EEG)
Matlab toolbox, all released under the Gnu public license (see eeglablicence.txt). 
See the EEGLAB tutorial and reference paper (URLs given below) for more information.

Sub-directories:

/src - Location of all MatClassRSA functions and helper functions

/examples - Locations of examples and illustrative analyses

Dependencies:

The software is compatible with Matlab 2016b and above.  Some functions may be usable on earlier versions of MATLAB, 
but it has not been fully tested on previous versions.  
The software requires two Matlab toolboxes:  the Statistics and Machine Learning Toolbox and the Image Processing Toolbox.

To use EEGLAB: 

Download the latest version of this package at https://github.com/berneezy3/MatClassRSA/

Upon startup of Matlab, run the following in the Matlab IDE to add the MatClassRSA functions into your search path:

> downloadPath = <Your download directory here, in char array format>;
> addpath([downloadPath 'src/Classification/libsvm-3.21/matlab']);
> addpath([downloadPath 'src/Classification/']);
> addpath([downloadPath 'src/RDM_Computation/');
> addpath([downloadPath 'src/Visualization']);

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
