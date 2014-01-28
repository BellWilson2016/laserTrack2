% startTracking.m
%
% JSB 11/2012

global vid;				% Global video object
global RG;				% Global regenerating DAQ object
global trackingParams;	% Global tracking parameters
global USBwatchdog;
global softwareWatchdog;

cd('~/Desktop/Code/laserTrack2');	% Change to laserTrack directory

warning('off','MATLAB:JavaEDTAutoDelegation');
imaqreset();				% Closes and open video objects
if (~isempty(instrfind))
    fclose(instrfind);      % Closes any MATLAB open serial ports
end

% USBolfactometer = initializeArduino();
% setValve(0,0);
% USBscanController =   initializeScanController();
% USBshockController = initializeShockController();

softwareWatchdog = startSoftwareWatchdog(true);

USBwatchdog = initializeHardwareWatchdog();
USBwatchdogTimer = timer('ExecutionMode','fixedRate','Period',15,'TimerFcn',@checkWatchdog, 'StartDelay', 15);
start(USBwatchdogTimer);

RG = regeneratingDAC('Dev1');		% Setup regenerating DAC output
RG.setupTiming();					% Set the clocks
RG.start();							% Start the output running

vid = setupTrackingCamera();

showRawView();

trackingParams.getStd = false;
trackingParams.trackThresh = 50;
trackingParams.invert = false;
     
showAvgView;
setAvg(true);
disp('Averaging background...');
pause(5);
setAvg(false);
showFlyView;
    
% Set tracking laser to fly
loadLaserCal();
setScanMirrors(true);
setTrackHead(true);







