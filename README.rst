laserTrack2
===========

Code for read time video tracking of multiple walking flies, and steering lasers to the flies using scan mirrors, as described in Bell and Wilson, 2016. This code is likely not runnable on your system.

Basics:
-------
This is designed to run in MATLAB in Linux. (We found that Linux gave us better stability and was easier to manage remotely.) Because when we wrote this MATLAB does not provide a DAQ Toolbox for Linux, we wrote some code to interface with the NI's DAQmx drivers <a href="http://www.github.com/joebell/jDAQmx">jDAQmx</a>.


