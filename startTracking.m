% startTracking.m
%
% JSB 11/2012

global vid;
global RG;
%global USBscanController;
%global USBshockController;
global trackingParams;

clearPorts();


% USBolfactometer = initializeArduino();
% setValve(0,0);
% USBscanController =   initializeScanController();
% USBshockController = initializeShockController();

RG = reGen('Dev1');		% Setup regenerating DAC output
vid = setupTrackingCamera();

showRawView();
disp('Running trackFly()...');
trackFly();



