% testScanController

clearPorts;
USBscanController = initializeScanController();

scanTimer = timer('ExecutionMode','fixedSpacing','Period',.033,...
    'TimerFcn',@scanTimerFcn);

start(scanTimer);

