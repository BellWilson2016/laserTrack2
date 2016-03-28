laserTrack2
===========

Code for read time video tracking of multiple walking flies, and steering lasers to the flies using scan mirrors, as described in Bell and Wilson, 2016. This code is likely not runnable on your system.

Basics:
-------
This is designed to run in MATLAB in Linux. (We found that Linux gave us better stability and was easier to manage remotely.) Because when we wrote this MATLAB does not provide a DAQ Toolbox for Linux, we wrote some code to interface with the NI's DAQmx drivers jDAQmx: http://www.github.com/joebell/jDAQmx. The program does real time analysis on a video stream from a firewire camera to detect positions of flies, saves the data, and outputs laser activation and galvonometer position commands via the DAQ.

Of note, in the event that the computer is unable to update the DAQ with new tracking data before it runs off the end of its buffer, the DAQ is programmed to regenerate samples from the beginning of this buffer. (The tracking data is always written into the buffer such that looping through the buffer constitutes a valid scan path for the mirrors.) This functionality is implemented in: regeneratingDAC.m

Tracking:
---------
Tracking is done by background subtracting and thresholding to yield an ellipse of pixels for each fly. The head/tail axis is detected by finding the first eigenvector of the covariance matrix of pixel locations. (This is just PCA; turns out to be faster than calling princomp()).

Example Usage:
--------------
From the command line to start tracking do:: 

    >> startTracking;

To define the current behavioral arena do::

    >> defineMultiArena();

To show raw video do:: 

    >> showRawView();

To show an annotated view of the current tracking do:: 

    >> showFlyView();

To start updating the running average of the background image:: 

    >> setAvg(true);

To stop it do:: 

    >> setAvg(false);

Running Experiments:
--------------------
To run experiments we used a scheduling script to schedule each trial throughout the day using MATLAB timers. Most data in the paper was collected using the script::

    >> singleSideSeriesShortRB();

This 'Experiment' defines all the trials, trial parameters and when they occur. The timing of events within an individual trial (eg. when the lasers will be active) are defined in 'Trial Protocols,' for example laser_1_halfL_1.m, which defines a 1 minute pre-laser period, a 30 second trial period with blue laser on 1 half of each arena, and a 1 minute post-trial period.

Short bits of code in the directory 'Laser Distributions' define the rules for turning the laser on or off in closed-loop based on the fly's behavior. The most commonly used distribution is laserFlatHalvesBR.m

Scripts of Interest:
--------------------
calibrateLaser.m    - Script for mapping galvanometer voltages onto laser locations in pixel space.

regeneratingDAC.m   - Script that talks to the NIDAQmx.

liveTrack.m         - Most of the actual tracking is done in here.

livePreview.m       - Video markup and display happens here.










