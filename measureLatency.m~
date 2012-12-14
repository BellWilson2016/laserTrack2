function measureLatency()

	global trackingParams;

	% Frames to drop each time
	nFrames = 6;
	fileN = nextFileNumber();

	% Setup an experiment to run
	exp.experimentName = ['latencyMeasurement'];
	powerL = 0;
	powerR = 10;	
	% exp.protocol	 = @laser_1_2L_1_2Rx4;
	exp.protocol	 = @laser_1_2L; 	expLength = 3;
	exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
	runLaserProtocol(exp);

	frameDropTimer = timer('ExecutionMode','fixedRate','Period',3,...
        'TimerFcn',{@dropFrameFcn, nFrames}, 'StartDelay',3,'TasksToExecute',expLength*60/3);

	start(frameDropTimer);


function dropFrameFcn(obj,event,nFrames)

	setScanMode([3,nFrames,0]);



	
