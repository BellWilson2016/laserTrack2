% startTracking.m
%
% JSB 11/2012

global vid;

clearPorts();

% USBolfactometer = initializeArduino();
% setValve(0,0);
USBscanController =   initializeScanController();

vid = setupTrackingCamera();

showRawView();
disp('Running trackFly()...');
trackFly();



