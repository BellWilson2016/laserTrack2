laserTrack2
===========

Code for read time video tracking of multiple walking flies, and steering lasers to the flies using scan mirrors, as described in Bell and Wilson, 2016. This code is likely not runnable on your system.

Basics:
-------
This is designed to run in MATLAB in Linux. (We found that Linux gave us better stability and was easier to manage remotely.) Because when we wrote this MATLAB does not provide a DAQ Toolbox for Linux, we wrote some code to interface with the NI's DAQmx drivers jDAQmx: http://www.github.com/joebell/jDAQmx . The program does real time analysis on a video stream from a firewire camera to detect positions of flies, saves the data, and outputs laser activation and galvonometer position commands via the DAQ.

Tracking:
---------
Tracking is done by background subtracting and thresholding to yield an ellipse of pixels for each fly. The head/tail axis is detected by finding the first eigenvector of the covariance matrix of pixel locations. (This is just PCA; turns out to be faster than calling princomp()).

Example Usage:
--------------
From the command line to start tracking do:: >> startTracking;

To define the current behavioral arena do:: >> defineMultiArena();

To show raw video do:: >> showRawView();

To show an annotated view of the current tracking do:: >> showFlyView();

To start updating the running average of the background image:: >> setAvg(true);

To stop it do:: >> setAvg(false);






