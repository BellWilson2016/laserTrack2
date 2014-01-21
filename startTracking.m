% startTracking.m
%
% JSB 11/2012

global vid;				% Global video object
global RG;				% Global regenerating DAQ object
global trackingParams;	% Global tracking parameters

cd('~/Desktop/Code/laserTrack2');	% Change to laserTrack directory

if (~isempty(instrfind))
    fclose(instrfind);      % Closes any MATLAB open serial ports
end

% USBolfactometer = initializeArduino();
% setValve(0,0);
% USBscanController =   initializeScanController();
% USBshockController = initializeShockController();

RG = regeneratingDAC('Dev1');		% Setup regenerating DAC output
RG.setupTiming();					% Set the clocks
RG.start();							% Start the output running

vid = setupTrackingCamera();

showRawView();

trackingParams.getStd = false;
trackingParams.trackThresh = 50;
trackingParams.invert = false;
    
vcam(6000, 250);    
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




