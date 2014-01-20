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

RG = reGen('Dev1');		% Setup regenerating DAC output
RG.setupTiming();		% Set the clocks
RG.start();				% Start the output running

vid = setupTrackingCamera();

showRawView();

setScanParameters();
trackingParams.getStd = false;
trackingParams.trackThresh = 50;
trackingParams.invert = false;
    
mcam(6000);    
showAvgView;
setAvg(true);
pause(5);
setAvg(false);
showFlyView;
    
% Set tracking laser to fly
loadLaserCal();
setScanMirrors(true);




