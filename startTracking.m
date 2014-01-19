% startTracking.m
%
% JSB 11/2012

global vid;				% Global video object
global RG;				% Global regenerating DAQ object
global trackingParams;	% Global tracking parameters

clearPorts();			% Clear all serial ports

% USBolfactometer = initializeArduino();
% setValve(0,0);
% USBscanController =   initializeScanController();
% USBshockController = initializeShockController();

%matlabpool close;
%matlabpool open 2;

RG = reGen('Dev1');		% Setup regenerating DAC output
RG.setupTiming();		% Set the clocks
RG.start();				% Start the output running

vid = setupTrackingCamera();

showRawView();
disp('Running trackFly()...');
trackFly();




