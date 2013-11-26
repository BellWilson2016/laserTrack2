% startTracking.m
%
% JSB 11/2012

global vid;
global USBscanController;
global USBshockController;
global trackingParams;

clearPorts();

%setupRemotePHP();   % Setup a remote PHP script that can pull data from
%					 % the local webserver.

% USBolfactometer = initializeArduino();
% setValve(0,0);
USBscanController =   initializeScanController();
%USBshockController = initializeShockController();

vid = setupTrackingCamera();

showRawView();
disp('Running trackFly()...');
trackFly();



